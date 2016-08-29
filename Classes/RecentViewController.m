//
//  RecentTableViewController.m
//  Conversa
//
//  Created by Edgar Gomez on 1/31/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

#import "RecentViewController.h"

#import "Log.h"
#import "Colors.h"
#import "Business.h"
#import "Constants.h"
#import "YapSearch.h"
#import "DatabaseView.h"
#import "PFSearchQueue.h"
#import "DatabaseManager.h"
#import "CustomSearchCell.h"
#import "ProfileViewController.h"
#import "NSFileManager+Conversa.h"
#import <YapDatabase/YapDatabaseView.h>

@interface RecentViewController ()

@property (nonatomic, strong) NSString *searchWith;
@property (nonatomic, strong) YapDatabaseConnection *databaseConnection;
@property (nonatomic, strong) YapDatabaseViewMappings *recentMappings;

@property(nonatomic) BOOL visible;

@end

@implementation RecentViewController

#pragma mark - Lifecycle Methods -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomSearchCell" bundle:nil] forCellReuseIdentifier:@"CustomSearchCell"];
    
    // Freeze our connection for use on the main-thread.
    // This gives us a stable data-source that won't change until we tell it to.
    self.databaseConnection       = [[DatabaseManager sharedInstance] newConnection];
    self.databaseConnection.name  = NSStringFromClass([self class]);
    [self.databaseConnection beginLongLivedReadTransaction];
    
    self.recentMappings = [[YapDatabaseViewMappings alloc] initWithGroups:@[RecentSearchGroup]
                                                                     view:RecentSearhDatabaseViewExtensionName];
    
    [self.databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        [self.recentMappings updateWithTransaction:transaction];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(yapDatabaseModified:)
                                                 name:YapDatabaseModifiedNotification
                                               object:[DatabaseManager sharedInstance].database];
    
    // Remove extra lines
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:v];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YapDatabaseModifiedNotification object:[DatabaseManager sharedInstance].database];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [Colors greenColor];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:SEARCH_NOTIFICATION_NAME
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.visible = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SEARCH_NOTIFICATION_NAME object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // We are now visible
    self.visible = NO;
}

- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:SEARCH_NOTIFICATION_NAME]) {
        [self runQueryWithParameter:([notification.userInfo objectForKey:SEARCH_NOTIFICATION_DIC_KEY]) ? [notification.userInfo objectForKey:SEARCH_NOTIFICATION_DIC_KEY] : @""];
    }
}

- (void) runQueryWithParameter:(NSString *)search {
    self.searchWith = [search copy];
    if ([search length]) {
        [self loadObjects];
    } else {
        [[PFSearchQueue searchInstance] clearPFQueryQueue];
        [self clear];
    }
}

#pragma mark - PFQueryTableViewController Methods -

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = NO;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 13;
    }
    return self;
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    // This method is called before a PFQuery is fired to get more objects
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    // This method is called every time objects are loaded from Parse via the PFQuery
}

- (PFQuery *)baseQuery {    
    PFQuery *query = [Business query];
    [query selectKeys:@[kBusinessBusinessInfoKey, kBusinessConversaIdKey]];
    
    [query includeKey:kBusinessBusinessInfoKey];
    [query whereKey:kBusinessActiveKey  equalTo:@(YES)];
    [query whereKey:kBusinessCountryKey equalTo:[PFObject objectWithoutDataWithClassName:@"Country" objectId:@"QZ31UNerIj"]];
    [query whereKeyDoesNotExist:kBusinessBusinessKey];
    
    if ([self.searchWith length]) {
        PFQuery *param1 = [Account query];
        [param1 whereKey:kUserUsernameKey containsString:self.searchWith];
        [param1 whereKey:kUserTypeKey equalTo:@(NO)];
        
        [query whereKey:kBusinessConversaIdKey containsString:self.searchWith];
        [query whereKey:kBusinessBusinessInfoKey matchesKey:kObjectRowObjectIdKey inQuery:param1];
    }
    
    [query orderByAscending:kBusinessCategoryPositionKey];
    [query addAscendingOrder:kObjectRowCreatedAtKey];
    
    [[PFSearchQueue searchInstance] enqueuePFQuery:query];
    
    return query;
}

- (PFQuery *)queryForTable {
    return [self baseQuery];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *simpleTableIdentifier = @"CustomSearchCell";
    CustomSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    if (cell == nil) {
        cell = [[CustomSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }

    // Configure the cell
    Business *bs = nil;
    
    if (object) {
        bs = (Business *)object;
        [cell configureCellWith:bs];
    } else {
        YapSearch *search = [self searchAtIndexPath:indexPath];
        bs = [Business objectWithoutDataWithObjectId:search.uniqueId];
        Account *account = [Account objectWithoutDataWithObjectId:search.userObjectId];
        bs.displayName = search.displayName;
        bs.conversaID   = search.conversaId;
        bs.businessInfo = account;
        [cell configureCellWith:bs withAvatar:[UIImage imageWithData:search.avatar]];
    }
    
    return cell;
}

#pragma mark - UITableViewDataSource Methods - 

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.searchWith length] == 0) {
        return @"Recientes";
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.searchWith length] == 0) {
        return [self.recentMappings numberOfItemsInSection:section];
    }
    
    return [self.objects count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - UITableViewDelegate Methods -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __block BOOL save = YES;
    CustomSearchCell *cell = (CustomSearchCell *)[tableView cellForRowAtIndexPath:indexPath];
    Business *business = cell.business;
    
    [[PFSearchQueue searchInstance] clearPFQueryQueue];
    
    [[DatabaseManager sharedInstance].newConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
        
        YapSearch *search = [transaction objectForKey:cell.business.objectId inCollection:[YapSearch collection]];
        
        if(search) {
            search.avatar = UIImageJPEGRepresentation(cell.photoImageView.image, 0.8);
            search.searchDate = [NSDate date];
            [search saveWithTransaction:transaction];
            save = NO;
        }
    } completionBlock:^{
        if (save) {
            YapSearch *newSearch = [[YapSearch alloc] initWithUniqueId:business.objectId];
            newSearch.userObjectId = business.businessInfo.objectId;
            newSearch.conversaId = business.conversaID;
            newSearch.displayName = business.displayName;
            newSearch.avatar = UIImageJPEGRepresentation(cell.photoImageView.image, 0.8);
            newSearch.searchDate = [NSDate date];
            [newSearch saveNew];
        }
    }];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navigationController1 = [storyboard instantiateViewControllerWithIdentifier:@"profileNavigationController"];
    navigationController1.modalPresentationStyle = UIModalPresentationFormSheet;
    navigationController1.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    ProfileViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    vc.business = business;
    vc.enable   = YES;
    [navigationController1 setViewControllers:@[vc] animated:YES];
    [[self topMostController] presentViewController:navigationController1 animated:YES completion:nil];
}

#pragma mark - Find Method -

- (UIViewController*) topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

- (YapSearch *)searchAtIndexPath:(NSIndexPath *)indexPath {
    __block YapSearch *search = nil;
    
    [self.databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        YapDatabaseViewTransaction *viewTransaction = [transaction ext:RecentSearhDatabaseViewExtensionName];
        NSUInteger row = indexPath.row;
        NSUInteger section = indexPath.section;
        
        NSAssert(row < [self.recentMappings numberOfItemsInSection:section], @"Cannot fetch search because row %d is >= numberOfItemsInSection %d", (int)row, (int)[self.recentMappings numberOfItemsInSection:section]);
        
        search = [viewTransaction objectAtRow:row inSection:section withMappings:self.recentMappings];
        NSParameterAssert(search != nil);
    }];
    
    return search;
}

#pragma mark - YapDatabase Method -

- (void)yapDatabaseModified:(NSNotification *)notification
{
    // Jump to the most recent commit.
    // End & Re-Begin the long-lived transaction atomically.
    // Also grab all the notifications for all the commits that I jump.
    // If the UI is a bit backed up, I may jump multiple commits.
    NSArray *notifications  = [self.databaseConnection beginLongLivedReadTransaction];
    
    if ([notifications count] <= 0) {
        // Since we moved our databaseConnection to a new commit,
        // we need to update the mappings too.
        [self.databaseConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
            [self.recentMappings updateWithTransaction:transaction];
        }];
        return; // Already processed commit
    }
    
    // If the view isn't visible, we might decide to skip the UI animation stuff.
    if (!self.visible || [self.searchWith length]) {
        // Since we moved our databaseConnection to a new commit,
        // we need to update the mappings too.
        [self.databaseConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction){
            [self.recentMappings updateWithTransaction:transaction];
        }];
        return;
    }
    
    if ([self.searchWith length]) {
        return;
    }
    
    NSArray *recentRowChanges = nil;
    
    [[self.databaseConnection ext:RecentSearhDatabaseViewExtensionName] getSectionChanges:nil
                                                                        rowChanges:&recentRowChanges
                                                                  forNotifications:notifications
                                                                      withMappings:self.recentMappings];
    
    if([recentRowChanges count] == 0) {
        return;
    }
    
    // Familiar with NSFetchedResultsController?
    // Then this should look pretty familiar
    
    [self.tableView beginUpdates];
    
    for (YapDatabaseViewRowChange *rowChange in recentRowChanges)
    {
        switch (rowChange.type)
        {
            case YapDatabaseViewChangeDelete :
            {
                [self.tableView deleteRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeInsert :
            {
                [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeMove :
            {
                [self.tableView deleteRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeUpdate :
            {
                [self.tableView reloadRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }
    
    [self.tableView endUpdates];
}

@end
