//
//  CategoryViewController.m
//  Conversa
//
//  Created by Edgar Gomez on 12/14/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "TagsViewController.h"

#import "Log.h"
#import "Colors.h"
#import "Business.h"
#import "YapSearch.h"
#import "Constants.h"
#import "PFSearchQueue.h"
#import "DatabaseManager.h"
#import "CustomSearchCell.h"
#import "CustomChatButton.h"
#import "ProfileViewController.h"
#import "ConversationViewController.h"

@interface TagsViewController()

@property (nonatomic, strong) NSString *searchWith;

@end

@implementation TagsViewController

#pragma mark - Lifecycle Methods -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomSearchCell" bundle:nil] forCellReuseIdentifier:@"CustomSearchCell"];
    
    // Remove extra lines
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:v];
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

- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:SEARCH_NOTIFICATION_NAME]) {
        [self runQueryWithParameter:([notification.userInfo objectForKey:SEARCH_NOTIFICATION_DIC_KEY]) ? [notification.userInfo objectForKey:SEARCH_NOTIFICATION_DIC_KEY] : @""];
    }
}

- (void) runQueryWithParameter:(NSString *)search {
    search = [search stringByReplacingOccurrencesOfString:@" " withString:@""];
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
        self.objectsPerPage = 20;
    }
    return self;
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
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
        [param1 whereKey:kUserTypeKey equalTo:@(NO)];
        
        [query whereKey:kBusinessBusinessInfoKey matchesKey:kObjectRowObjectIdKey inQuery:param1];
        [query whereKey:kBusinessTagTagKey equalTo:self.searchWith];
    }
    
    [query orderByAscending:kBusinessCategoryPositionKey];
    [query addAscendingOrder:kObjectRowCreatedAtKey];
    
    [[PFSearchQueue searchInstance] enqueuePFQuery:query];
    
    return query;
}

- (PFQuery *)queryForTable {
    return [self baseQuery];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"CustomSearchCell";
    CustomSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[CustomSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Business *bs = (Business*)object;
    
    // Configure the cell
    [cell configureCellWith:bs];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NextPage";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = @"Load more...";
    
    return cell;
}

#pragma mark - UITableViewDelegate Method -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Business *business = (Business*)[self objectAtIndexPath:indexPath];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[PFSearchQueue searchInstance] clearPFQueryQueue];
    });
    
    CustomSearchCell *cell = (CustomSearchCell *)[tableView cellForRowAtIndexPath:indexPath];
    YapSearch *newSearch = [[YapSearch alloc] initWithUniqueId:business.objectId];
    newSearch.userObjectId = business.businessInfo.objectId;
    newSearch.conversaId = business.conversaID;
    newSearch.displayName= business.displayName;
    newSearch.avatar     = UIImageJPEGRepresentation(cell.photoImageView.image, 0.8);
    newSearch.searchDate = [NSDate date];
    [newSearch saveNew];
    
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

@end