//
//  PopularViewController.m
//  Conversa
//
//  Created by Edgar Gomez on 1/28/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

#import "PopularViewController.h"

#import "Log.h"
#import "Colors.h"
#import "Constants.h"
#import "YapSearch.h"
#import "PopularSearch.h"
#import "PFSearchQueue.h"
#import "DatabaseManager.h"
#import "CustomSearchCell.h"
#import "ProfileViewController.h"

@interface PopularViewController ()

@property (nonatomic, strong) NSString *searchWith;

@end

@implementation PopularViewController

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
    // This method is called before a PFQuery is fired to get more objects
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    // This method is called every time objects are loaded from Parse via the PFQuery
}

- (PFQuery *)baseQuery {
    PFQuery *query = [PopularSearch query];
    [query selectKeys:@[kStatisticsBusinessKey]];
    
    [query includeKey:
     [kStatisticsBusinessKey stringByAppendingString:[@"." stringByAppendingString:kBusinessBusinessInfoKey]]];
    
    if ([self.searchWith length]) {
        PFQuery *param1 = [Account query];
        [param1 whereKey:kUserUsernameKey containsString:self.searchWith];
        [param1 whereKey:kUserTypeKey equalTo:@(NO)];

        PFQuery *subParam1 = [Business query];
        [subParam1 whereKey:kBusinessBusinessInfoKey matchesKey:kObjectRowObjectIdKey inQuery:param1];
        [subParam1 whereKey:kBusinessActiveKey  equalTo:@(YES)];
        [subParam1 whereKey:kBusinessConversaIdKey containsString:self.searchWith];
        [subParam1 whereKey:kBusinessCountryKey equalTo:[PFObject objectWithoutDataWithClassName:@"Country" objectId:@"QZ31UNerIj"]];
        [subParam1 whereKeyDoesNotExist:kBusinessBusinessKey];
        [query whereKey:kStatisticsBusinessKey matchesKey:kObjectRowObjectIdKey inQuery:subParam1];
    }
    
    [query orderByAscending:kStatisticsCriteria1Key];
    [query addAscendingOrder:kStatisticsCriteria2Key];
    [query addAscendingOrder:kStatisticsCriteria3Key];
    [query addAscendingOrder:kStatisticsCriteria4Key];
    [query addDescendingOrder:kStatisticsCriteria5Key];
    [query addDescendingOrder:kStatisticsCriteria6Key];
    
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
    PopularSearch *bs = (PopularSearch *)object;
    [cell configureCellWith:bs.business];
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Business *business = ((PopularSearch*) [self objectAtIndexPath:indexPath]).business;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[PFSearchQueue searchInstance] clearPFQueryQueue];
    });
    
    CustomSearchCell *cell = (CustomSearchCell *)[tableView cellForRowAtIndexPath:indexPath];
    YapSearch *newSearch = [[YapSearch alloc] initWithUniqueId:business.objectId];
    newSearch.userObjectId = business.businessInfo.objectId;
    newSearch.conversaId = business.conversaID;
    newSearch.displayName = business.displayName;
    newSearch.avatar = UIImageJPEGRepresentation(cell.photoImageView.image, 0.8);
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
