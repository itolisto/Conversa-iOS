//
//  CategoryViewController.h
//  Conversa
//
//  Created by Edgar Gomez on 12/14/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "CategoriesViewController.h"

#import "Log.h"
#import "Flurry.h"
#import "Colors.h"
#import "Constants.h"
#import "nCategory.h"
#import "nHeaderTitle.h"
#import "SettingsKeys.h"
#import "UIStateButton.h"
#import "Conversa-Swift.h"
#import "ParseValidation.h"
#import "CustomCategoryCell.h"
#import "SearchViewController.h"
#import "CategoryViewController.h"
#import "CustomCategoryHeaderCell.h"

@interface CategoriesViewController ()

@property (strong, nonatomic) NSMutableArray<nHeaderTitle *> *_headers;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSArray<nCategory *>*> *_dictionary;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UIView *noConnectionView;
@property (weak, nonatomic) IBOutlet UIStateButton *retryButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *bbiFavs;

@end

@implementation CategoriesViewController

#pragma mark - Lifecycle Methods -

- (void)viewDidLoad {
    [super viewDidLoad];

    self.searchView.hidden = YES;

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self._dictionary = [NSMutableDictionary dictionaryWithCapacity:2];
    self._headers = [NSMutableArray arrayWithCapacity:2];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(_refreshControlValueChanged:)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self.tableView addSubview:self.refreshControl];

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];

    self.searchController.searchBar.showsScopeBar = NO;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.placeholder = NSLocalizedString(@"categories_searchbar_placeholder", nil);
    // If we are using this same view controller to present the results
    // dimming it out wouldn't make sense.  Should set probably only set
    // this to yes if using another controller to display the search results.
    self.searchController.dimsBackgroundDuringPresentation = NO;
    // By default the navigation bar hides when presenting the
    // search interface.  Obviously we don't want this to happen if
    // our search bar is inside the navigation bar.
    self.searchController.hidesNavigationBarDuringPresentation = false;

    // Sets this view controller as presenting view controller for the search interface
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];

    self.navigationItem.titleView = self.searchController.searchBar;
    //self.navigationController.view.backgroundColor = [Colors greenNavbar];

    // Add retry button properties
    [self.retryButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
    [self.retryButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.retryButton setBackgroundColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.retryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

    // Load initial data
    self.searchMode = NO;

    // Remove extra lines
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:v];

    // Remove 1px bottom line
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init]
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];

    self.navigationController.navigationBar.barTintColor = [Colors greenNavbar];

    [self loadObjects];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.searchMode) {
        self.navigationController.navigationBar.barTintColor = [Colors whiteNavbar];
        self.navigationController.navigationBar.tintColor = [Colors black];
    } else {
        self.navigationController.navigationBar.barTintColor = [Colors greenNavbar];
        self.navigationController.navigationBar.tintColor = [Colors white];
    }

//    if (self.elissa == nil) {
//        ElissaConfiguration *elissaConfig = [ElissaConfiguration new];
//        elissaConfig.message = @"Find your favorites here";
//        elissaConfig.image = [UIImage imageNamed:@"heartIcon"];
//        elissaConfig.font = [UIFont systemFontOfSize:17];
//        elissaConfig.textColor = [UIColor redColor];
//        elissaConfig.backgroundColor = [UIColor greenColor];
//        elissaConfig.arrowOffset = 60.0;
//
//        self.elissa = [[self view] showElissaFromSourceView:self.searchController.searchBar configuration:elissaConfig onTouchHandler:^{
//            [self.elissa removeFromSuperview];
//            self.elissa = nil;
//        }];
//    }
//    [[GuideViewsManager sharedInstance] showWithText:@"89fadslkjafds21"
//                                           direction:3
//                                            maxWidth:200.0
//                                              inview:self.view
//                                                from:self.searchController.searchBar.frame
//                                            duration:0];
}

- (IBAction)retryButtonPressed:(UIStateButton *)sender {
    [self loadObjects];
}

#pragma mark - Data Methods -

- (void)loadObjects {
    NetworkStatus networkStatus = [self.networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        self.noConnectionView.hidden = NO;
    } else {
        self.noConnectionView.hidden = YES;

        NSString *language = [[[NSLocale preferredLanguages] objectAtIndex:0] substringToIndex:2];

        if (![language isEqualToString:@"es"] && ![language isEqualToString:@"en"]) {
            language = @"en"; // Set to default language
        }

        // TODO: Replace with networking layer
//        [NetworkingManager getCategoriesWithLanguage:language completion:^(NSString * _Nonnull response) {
//            NSLog(response);
//        }];

//        [PFCloud callFunctionInBackground:@"getCategories"
//                           withParameters:@{@"language": language}
//                                    block:^(NSString *json, NSError *error)
//         {
//             if (error) {
//                 [self.refreshControl endRefreshing];
//                 if ([ParseValidation validateError:error]) {
//                     [ParseValidation _handleInvalidSessionTokenError:self];
//                 }
//             } else {
//                 [self._dictionary removeAllObjects];
//                 [self._headers removeAllObjects];
//
//                 NSData *objectData = [json dataUsingEncoding:NSUTF8StringEncoding];
//                 NSArray *results = [NSJSONSerialization JSONObjectWithData:objectData
//                                                                    options:NSJSONReadingMutableContainers
//                                                                      error:&error];
//                 if (error) {
//                     // Show error
//                     [self.refreshControl endRefreshing];
//                 } else {
//                     NSUInteger size = [results count];
//
//                     for (int i = 0; i < size; i++) {
//                         NSDictionary *object = [results objectAtIndex:i];
//
//                         nHeaderTitle *title = [[nHeaderTitle alloc] init];
//                         title.headerName = [object objectForKey:@"tn"];
//                         [self._headers addObject:title];
//
//                         NSArray *categories = [object objectForKey:@"cat"];
//                         NSMutableArray *categoriesInSection = [NSMutableArray arrayWithCapacity:2];
//                         NSUInteger categoriesSize = [categories count];
//
//                         for (int h = 0; h < categoriesSize; h++) {
//                             NSDictionary *category = [categories objectAtIndex:h];
//
//                             nCategory *categoryReg = [[nCategory alloc] init];
//                             categoryReg.objectId = [category objectForKey:@"ob"];
//                             categoryReg.name = [category objectForKey:@"na"];
//                             categoryReg.avatarUrl = [category objectForKey:@"th"];
//                             categoryReg.custom = ([category objectForKey:@"cs"]) ? YES : NO;
//
//                             [categoriesInSection addObject:categoryReg];
//                         }
//                         
//                         [self._dictionary setObject:categoriesInSection
//                                              forKey:[NSNumber numberWithInt:i]];
//                     }
//                     
//                     [self.refreshControl endRefreshing];
//                     [self.tableView reloadData];
//                 }
//             }
//         }];
    }
}

- (void)_refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self loadObjects];
}

- (NSArray *)arrayAtIndexPath:(NSIndexPath *)indexPath {
    return [self._dictionary objectForKey:[NSNumber numberWithInteger:[indexPath section]]];
}

- (nCategory *)objectAtIndexPath:(NSIndexPath *)indexPath {
    return [[self arrayAtIndexPath:indexPath] objectAtIndex:[indexPath row]];
}

#pragma mark - UITableViewDataSource Methods -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self._headers count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self arrayAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    NSObject *category = (NSObject *)[self objectAtIndexPath:indexPath];

    static NSString *simpleTableIdentifier = @"CustomCategoryCell";
    cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    if (cell == nil) {
        cell = [[CustomCategoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }

    bool hide = YES;

    // Configure the cell
    if (indexPath.row + 1 < [[self arrayAtIndexPath:indexPath] count]) {
        hide = NO;
    }

    [((CustomCategoryCell *)cell) configureCellWith:(nCategory *)category hideView:hide];

    return cell;
}

#pragma mark - UITableViewDelegate Methods -

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *CellIdentifier = @"CustomCategoryHeaderCell";
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (headerView == nil) {
        [NSException raise:@"headerView == nil.." format:@"No cells with matching CellIdentifier loaded from your storyboard"];
    }

    UILabel *label = (UILabel *)[headerView viewWithTag:223];
    [label setText:[self._headers objectAtIndex:section].headerName];

    return headerView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - UISearchBarDelegate Method -

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if ([searchText length] == 0) {
        [self sendSearchRequest:@""];
    } else {
        [self performSelector:@selector(sendSearchRequest:) withObject:searchText.lowercaseString afterDelay:0.4f];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName:SEARCH_NOTIFICATION_NAME
                                                        object:nil
                                                      userInfo:@{SEARCH_NOTIFICATION_DIC_KEY: searchBar.text}];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if (!self.searchMode) {
        self.searchMode = YES;
        self.searchView.hidden = NO;
        for (UIView *subView in searchBar.subviews) {
            for(id field in subView.subviews){
                if ([field isKindOfClass:[UITextField class]]) {
                    UITextField *textField = (UITextField *)field;
                    [textField setBackgroundColor:[Colors searchBar]];
                    break;
                }
            }
        }
//        [self.navigationController.navigationItem setRightBarButtonItems:nil animated:YES];
        
        self.navigationController.navigationBar.barTintColor = [Colors whiteNavbar];
        self.navigationController.navigationBar.tintColor = [Colors black];
        [searchBar setShowsCancelButton:YES animated:YES];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if (self.searchMode) {
        self.searchMode = NO;
        self.searchView.hidden = YES;
        for (UIView *subView in searchBar.subviews) {
            for(id field in subView.subviews){
                if ([field isKindOfClass:[UITextField class]]) {
                    UITextField *textField = (UITextField *)field;
                    [textField setBackgroundColor:[UIColor whiteColor]];
                    break;
                }
            }
        }
//        [self.navigationController.navigationItem setRightBarButtonItems:@[self.bbiFavs] animated:YES];
        self.navigationController.navigationBar.barTintColor = [Colors greenNavbar];
        self.navigationController.navigationBar.tintColor = [Colors white];
        [[NSNotificationCenter defaultCenter] postNotificationName:SEARCH_NOTIFICATION_NAME
                                                            object:nil
                                                          userInfo:@{SEARCH_NOTIFICATION_DIC_KEY: @""}];
        [searchBar setShowsCancelButton:NO animated:YES];
    }
}

- (void)sendSearchRequest:(NSString*)searchText {
    [[NSNotificationCenter defaultCenter] postNotificationName:SEARCH_NOTIFICATION_NAME
                                                        object:nil
                                                      userInfo:@{SEARCH_NOTIFICATION_DIC_KEY: searchText}];
}

#pragma mark - Navigation Method -

- (IBAction)goToFavsPressed:(UIBarButtonItem *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Favoritevt" bundle:nil];
    FavoritesViewController *rootViewController = (FavoritesViewController*)[storyboard instantiateViewControllerWithIdentifier:@"FavoritesVC"];
    rootViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:rootViewController animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"GoToSelectedCategory"]) {
        // Get reference to the destination view controller
        CategoryViewController *destinationViewController = [segue destinationViewController];
        CustomCategoryCell *cell = sender;
        nCategory *bs = cell.category;
        destinationViewController.navigationItem.title = [bs getName];
        if (@available(iOS 11.0, *)) {
            destinationViewController.navigationController.navigationBar.prefersLargeTitles = NO;
            destinationViewController.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
        }
        [Flurry logEvent:@"user_category_selected" withParameters:@{@"category":[bs getObjectId]}];
        // Pass any objects to the view controller here, like...
        [destinationViewController setCategoryId:bs.objectId];
        [destinationViewController setCustom:bs.custom];
    }
}

@end
