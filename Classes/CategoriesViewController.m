//
//  CategoryViewController.h
//  Conversa
//
//  Created by Edgar Gomez on 12/14/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "CategoriesViewController.h"

#import "Log.h"
#import "Colors.h"
#import "Constants.h"
#import "SettingsKeys.h"
#import "ParseValidation.h"
#import "CustomCategoryCell.h"
#import "SearchViewController.h"
#import "CategoryViewController.h"
#import "CustomCategoryHeaderCell.h"

#import "nHeaderTitle.h"
#import "nCategory.h"

@interface CategoriesViewController ()

@property (strong, nonatomic) NSMutableArray<NSObject *> *_mutableObjects;
@property (weak, nonatomic) IBOutlet UIView *searchView;
// Whether we have loaded the first set of objects
@property (nonatomic, assign) BOOL _firstLoad;
@property (nonatomic, assign) BOOL searchMode;
@property (nonatomic, assign) NSUInteger page;

@end

@implementation CategoriesViewController

#pragma mark - Lifecycle Methods -

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchView.hidden = YES;
    self.page = 0;

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self._mutableObjects = [NSMutableArray arrayWithCapacity:29];
    self._firstLoad = YES;

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(_refreshControlValueChanged:)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self.tableView addSubview:self.refreshControl];

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    // If we are using this same view controller to present the results
    // dimming it out wouldn't make sense.  Should set probably only set
    // this to yes if using another controller to display the search results.
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.showsScopeBar = NO;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.placeholder = NSLocalizedString(@"categories_searchbar_placeholder", nil);
    // Sets this view controller as presenting view controller for the search interface
    self.definesPresentationContext = YES;
    // Set SearchBar into NavigationBar
    self.tableView.tableHeaderView = nil;
    [self.searchController.searchBar sizeToFit];
    self.navigationItem.titleView = self.searchController.searchBar;
    // By default the navigation bar hides when presenting the
    // search interface.  Obviously we don't want this to happen if
    // our search bar is inside the navigation bar.
    self.searchController.hidesNavigationBarDuringPresentation = false;

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

    self.navigationController.navigationBar.barTintColor = [Colors greenColor];

    [self loadObjects];
}

#pragma mark - Data Methods -

- (void)loadObjects {
    NSString *language = [[[NSLocale preferredLanguages] objectAtIndex:0] substringToIndex:2];

    if (![language isEqualToString:@"es"] && ![language isEqualToString:@"en"]) {
        language = @"en"; // Set to default language
    }

    //DDLogError(@"Category after --> %@", language);

    [PFCloud callFunctionInBackground:@"getCategories"
                       withParameters:@{@"language": language}
                                block:^(NSString *json, NSError *error)
     {
         if (error) {
             [ParseValidation validateError:error controller:self];
         }

         [self._mutableObjects removeAllObjects];

         NSError *jsonError;
         NSData *objectData = [json dataUsingEncoding:NSUTF8StringEncoding];
         NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:objectData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];
         //kNilOptions
         if (jsonError || !jsonDic) {
             // Show error
         } else {
             NSArray *results =[jsonDic valueForKeyPath:@"results"];
             NSUInteger size = [results count];
             NSMutableArray *alphabetically = nil;

             for (int i = 0; i < size; i++) {
                 NSDictionary *object = [results objectAtIndex:i];
                 NSString *headerTitle = [object objectForKey:@"tn"];

                 if (headerTitle) {
                     nHeaderTitle *title = [[nHeaderTitle alloc] init];
                     title.headerName = headerTitle;
                     title.relevance = [[object objectForKey:@"re"] integerValue];
                     [self._mutableObjects addObject:title];

                     if ([object objectForKey:@"al"]) {
                         alphabetically = [[NSMutableArray alloc] initWithCapacity:1];
                     }
                 } else {
                     nCategory *category = [[nCategory alloc] init];
                     category.objectId = [object objectForKey:@"ob"];
                     category.avatarUrl = [object objectForKey:@"th"];

                     if (alphabetically) {
                         [alphabetically addObject:category];

                         if (i + 1 < size) {
                             object = [results objectAtIndex:i + 1];
                             if ([object objectForKey:@"tn"]) {
                                 NSArray *sortedArray = [alphabetically sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                                     NSString *first = [(nCategory*)obj1 getCategoryName];
                                     NSString *second = [(nCategory*)obj2 getCategoryName];
                                     return [first compare:second];
                                 }];
                                 [self._mutableObjects addObjectsFromArray:sortedArray];
                                 [alphabetically removeAllObjects];
                                 alphabetically = nil;
                             }
                         } else {
                             NSArray *sortedArray = [alphabetically sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                                 NSString *first = [(nCategory*)obj1 getCategoryName];
                                 NSString *second = [(nCategory*)obj2 getCategoryName];
                                 return [first compare:second];
                             }];
                             [self._mutableObjects addObjectsFromArray:sortedArray];
                             [alphabetically removeAllObjects];
                             alphabetically = nil;
                         }
                     } else {
                         [self._mutableObjects addObject:category];
                     }
                 }
             }

             [self.refreshControl endRefreshing];
             [self.tableView reloadData];
         }
     }];
}

- (void)_refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self loadObjects];
}

- (NSArray<__kindof NSObject *> *)objects {
    return __mutableObjects;
}

- (NSObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    return self.objects[indexPath.row];
}

#pragma mark - UITableViewDataSource Methods -

// Return the number of rows in the section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.objects count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *category = (NSObject *)[self objectAtIndexPath:indexPath];

    if ([category isKindOfClass:[nHeaderTitle class]]) {
        return 30.0;
    }

    return 70.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    NSObject *category = (NSObject *)[self objectAtIndexPath:indexPath];

    if ([category isKindOfClass:[nHeaderTitle class]]) {
        static NSString *simpleTableIdentifier = @"CustomCategoryHeaderCell";
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

        if (cell == nil) {
            cell = [[CustomCategoryHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }

        // Configure the cell
        [((CustomCategoryHeaderCell *)cell) configureCellWith:(nHeaderTitle *)category];
    } else {
        static NSString *simpleTableIdentifier = @"CustomCategoryCell";
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

        if (cell == nil) {
            cell = [[CustomCategoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }

        bool hide = NO;

        // Configure the cell
        if (indexPath.row + 1 < [[self objects] count]) {
            NSObject *ct = (NSObject *)[self objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row + 1 inSection:0]];

            if ([ct isKindOfClass:[nHeaderTitle class]]) {
                hide = YES;
            }
        }

        [((CustomCategoryCell *)cell) configureCellWith:(nCategory *)category hideView:hide];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods -

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
    searchBar.text = searchText.lowercaseString;
    [[NSNotificationCenter defaultCenter] postNotificationName:SEARCH_NOTIFICATION_NAME
                                                        object:nil
                                                      userInfo:@{SEARCH_NOTIFICATION_DIC_KEY: searchBar.text}];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
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
                    [textField setBackgroundColor:[Colors searchBarColor]];
                    break;
                }
            }
        }
        self.navigationController.navigationBar.tintColor = [Colors blackColor];
        self.navigationController.navigationBar.barTintColor = [Colors whiteColor];
        [self.view bringSubviewToFront:self.searchView];
    }
    [searchBar setShowsCancelButton:YES animated:YES];
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
        self.navigationController.navigationBar.barTintColor = [Colors greenColor];
        self.searchController.searchBar.placeholder = NSLocalizedString(@"categories_searchbar_placeholder", nil);
        [self.view sendSubviewToBack:self.searchView];

        [[NSNotificationCenter defaultCenter] postNotificationName:SEARCH_NOTIFICATION_NAME
                                                            object:nil
                                                          userInfo:@{SEARCH_NOTIFICATION_DIC_KEY: @""}];
    }
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - Navigation Method -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"GoToSelectedCategory"]) {
        // Get reference to the destination view controller
        CategoryViewController *destinationViewController = [segue destinationViewController];
        CustomCategoryCell *cell = sender;
        nCategory *bs = cell.category;
        destinationViewController.navigationItem.title = [bs getCategoryName];
        // Pass any objects to the view controller here, like...
        [destinationViewController setCategoryId:bs.objectId];
    }
}

@end
