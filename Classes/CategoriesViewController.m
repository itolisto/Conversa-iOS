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
#import "bCategory.h"
#import "SettingsKeys.h"
#import "CustomCategoryCell.h"
#import "SearchViewController.h"
#import "CategoryViewController.h"
#import <Parse/Parse.h>

@interface CategoriesViewController ()

@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (nonatomic, assign) BOOL searchMode;
@property (nonatomic, assign) NSUInteger page;

@end

@implementation CategoriesViewController

#pragma mark - Lifecycle Methods -

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchView.hidden    = YES;
    self.page = 0;
    
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
}

#pragma mark - Data Methods -

- (void)objectsWillLoad {
    [super objectsWillLoad];
    if([self.refreshControl isRefreshing]) {
        self.page = 0;
        [SettingsKeys setCategoriesLoad:0];
        [PFObject unpinAllInBackground:self.objects];
    }
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    if (![SettingsKeys getCategoriesLoad] && [self.objects count]) {
        [SettingsKeys setCategoriesLoad:self.page];
        [PFObject pinAllInBackground:self.objects];
    }
}

- (PFQuery *)baseQuery {
    PFQuery *query = [bCategory query];
    [query selectKeys:@[@"thumbnail"]];
    [query orderByDescending:@"relevance"];
    [query addDescendingOrder:@"position"];
    return ([SettingsKeys getCategoriesLoad] > 0) ? [query fromLocalDatastore] : query;
}

- (PFQuery *)queryForTable {
    return [self baseQuery];
}

#pragma mark - UITableViewDataSource Methods -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75.0;
}

- (PFTableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object
{
    static NSString *simpleTableIdentifier = @"CustomCategoryCell";
    CustomCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[CustomCategoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    // Configure the cell
    [cell configureCellWith:(bCategory *)object];
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.objects.count && self.paginationEnabled) {
        self.page = self.page + 1;
        // Load More Cell
        if (self.page > [SettingsKeys getCategoriesLoad]) {
            [SettingsKeys setCategoriesLoad:0];
            [PFObject unpinAllInBackground:self.objects];
        }
    }
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
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
    }
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - Navigation Method -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"GoToSelectedCategory"]) {
        // Get reference to the destination view controller
        CategoryViewController *destinationViewController = [segue destinationViewController];
        CustomCategoryCell *cell = sender;
        bCategory *bs = cell.category;
        destinationViewController.navigationItem.title = [bs getCategoryName];
        // Pass any objects to the view controller here, like...
        [destinationViewController setCategoryId:bs.objectId];
    }
}

@end
