//
//  SearchViewController.m
//  Conversa
//
//  Created by Edgar Gomez on 29/01/16.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "SearchViewController.h"

#import "Log.h"
#import "Colors.h"
#import "Business.h"
#import "Constants.h"
#import "YapSearch.h"
#import "DatabaseView.h"
#import "ParseValidation.h"
#import "DatabaseManager.h"
#import "CustomSearchCell.h"
#import "NSFileManager+Conversa.h"
#import "ProfileDialogViewController.h"
#import <YapDatabase/YapDatabaseView.h>

#import <stdlib.h>
#import <sys/sysctl.h>

@interface SearchViewController ()

@property (strong, nonatomic) NSMutableArray<YapSearch *> *_mutableObjects;
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *searchWith;
@property (nonatomic, strong) YapDatabaseConnection *databaseConnection;
@property (nonatomic, strong) YapDatabaseViewMappings *recentMappings;

@property (nonatomic, assign) NSUInteger searchId;
@property(strong, nonatomic) NSString *machine;

@end

@implementation SearchViewController

#pragma mark - Lifecycle Methods -

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self.tableView registerNib:[UINib nibWithNibName:@"CustomSearchCell" bundle:nil] forCellReuseIdentifier:@"CustomSearchCell"];

    self._mutableObjects = [NSMutableArray arrayWithCapacity:29];

    // Sets this view controller as presenting view controller for the search interface
    self.definesPresentationContext = YES;

    // Freeze our connection for use on the main-thread.
    // This gives us a stable data-source that won't change until we tell it to.
    self.databaseConnection = [[DatabaseManager sharedInstance] newConnection];
    self.databaseConnection.name = NSStringFromClass([self class]);
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

    // Remove 1px bottom line
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init]
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];

    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    self.machine = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SEARCH_NOTIFICATION_NAME object:nil];
}

#pragma mark - Search Methods -

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
        [self clear];
    }
}

- (void)clear {
    [__mutableObjects removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - Data Methods -

- (void)loadObjects {
    self.searchId = arc4random_uniform(4294967296);

    [PFCloud callFunctionInBackground:@"searchBusiness"
                       withParameters:@{@"search": self.searchWith, @"skip": @0, @"id" : @(self.searchId)}
                                block:^(NSString *json, NSError *error)
     {
         if (error) {
             [ParseValidation validateError:error controller:self];
         }

         NSData *objectData = [json dataUsingEncoding:NSUTF8StringEncoding];
         NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:objectData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&error];

         if (error) {
             // Show alert
         } else {
             if ([[jsonDic objectForKey:@"id"] unsignedIntegerValue] == self.searchId) {
                 [self._mutableObjects removeAllObjects];

                 NSArray *results =[jsonDic valueForKeyPath:@"results"];
                 NSUInteger size = [results count];

                 for (int i = 0; i < size; i++) {
                     NSDictionary *object = [results objectAtIndex:i];
                     YapSearch *newSearch = [[YapSearch alloc] initWithUniqueId:[object objectForKey:@"oj"]];
                     newSearch.conversaId = [object objectForKey:@"id"];
                     newSearch.displayName = [object objectForKey:@"dn"];
                     newSearch.avatarUrl = [object objectForKey:@"av"];
                     newSearch.searchDate = [NSDate date];
                     [self._mutableObjects addObject:newSearch];
                 }

                 [self.tableView reloadData];
             }
         }
     }];
}

- (NSArray<__kindof YapSearch *> *)objects {
    return __mutableObjects;
}

#pragma mark - UITableViewDataSource Methods -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0;
}

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
    if ([self.searchWith length] == 0) {
        return [self.recentMappings numberOfSections];
    }

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"CustomSearchCell";
    CustomSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    if (cell == nil) {
        cell = [[CustomSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }

    // Configure the cell
    [cell configureCellWithYap:[self searchAtIndexPath:indexPath]];

    return cell;
}

#pragma mark - UITableViewDelegate Methods -

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __block BOOL save = YES;
    __block YapSearch *business = ((CustomSearchCell *)[tableView cellForRowAtIndexPath:indexPath]).yapbusiness;
    YapDatabaseConnection *connection = [DatabaseManager sharedInstance].newConnection;

    [connection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
        YapSearch *search = [transaction objectForKey:business.uniqueId inCollection:[YapSearch collection]];

        if(search) {
            if ([self.searchWith length] > 0) {
                if (![search.avatarUrl isEqualToString:business.avatarUrl]) {
                    search.avatarUrl = business.avatarUrl;
                }
            }

            search.searchDate = [NSDate date];
            [search saveWithTransaction:transaction];
            save = NO;
        }
    } completionBlock:^{
        if (save) {
            business.searchDate = [NSDate date];
            [business saveNew:connection];
        }
    }];

    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];

    [ProfileDialogViewController controller:[self topMostController]
                                   business:nil
                                yapbusiness:business
                                     enable:YES
                                     device:self.machine];
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
    if ([self.objects count] && indexPath.row < [self.objects count]) {
        return self.objects[indexPath.row];
    } else if (indexPath.row < [self.recentMappings numberOfItemsInAllGroups]) {
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

    return nil;
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
    if ([self.searchWith length]) {
        // Since we moved our databaseConnection to a new commit,
        // we need to update the mappings too.
        [self.databaseConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction){
            [self.recentMappings updateWithTransaction:transaction];
        }];
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
