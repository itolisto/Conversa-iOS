//
//  CategoryViewController.m
//  Conversa
//
//  Created by Edgar Gomez on 12/14/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "CategoryViewController.h"

#import "Log.h"
#import "Constants.h"
#import "bCategory.h"
#import "CustomSearchCell.h"
#import "BusinessCategory.h"
#import "ProfileViewController.h"
#import "ConversationViewController.h"

@interface CategoryViewController()

@property NSInteger page;

@end

@implementation CategoryViewController

#pragma mark - Lifecycle Methods -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.objectsPerPage = 15;
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomSearchCell" bundle:nil] forCellReuseIdentifier:@"CustomSearchCell"];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // Remove extra lines
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [UIColor whiteColor];
    [self.tableView setTableFooterView:v];
}

#pragma mark - PFQueryTableViewController Methods -

- (PFQuery *)baseQuery {
    PFQuery *query = [BusinessCategory query];
    [query selectKeys:@[kBusinessCategoryBusinessKey]];
    
    [query includeKey:
     [kBusinessCategoryBusinessKey stringByAppendingString:[@"." stringByAppendingString:kBusinessBusinessInfoKey]]];
    [query whereKey:kBusinessCategoryCategoryKey equalTo:[bCategory objectWithoutDataWithObjectId:self.categoryId]];
    [query whereKey:kBusinessCategoryActiveKey   equalTo:@(YES)];
    
    PFQuery *param1 = [Business query];
    [param1 whereKey:kBusinessActiveKey  equalTo:@(YES)];
    [param1 whereKey:kBusinessCountryKey equalTo:[PFObject objectWithoutDataWithClassName:@"Country" objectId:@"QZ31UNerIj"]];
    [param1 whereKeyDoesNotExist:kBusinessBusinessKey];
    
    [query whereKey:kBusinessCategoryBusinessKey matchesKey:kObjectRowObjectIdKey inQuery:param1];
    
    [query orderByAscending:kBusinessCategoryRelevanceKey];
    [query addAscendingOrder:kBusinessCategoryPositionKey];
    
    [query setLimit:15];
    
    return query;
}

- (PFQuery *)queryForTable {
    return [self baseQuery];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *CellIdentifier = @"CustomSearchCell";
    CustomSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[CustomSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    BusinessCategory *bs = (BusinessCategory *)object;
    
    // Configure the cell
    [cell configureCellWith:bs.business];
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navigationController1 = [storyboard instantiateViewControllerWithIdentifier:@"profileNavigationController"];
    navigationController1.modalPresentationStyle = UIModalPresentationFormSheet;
    navigationController1.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    ProfileViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    vc.business = ((BusinessCategory*) [self objectAtIndexPath:indexPath]).business;
    vc.enable = YES;
    [navigationController1 setViewControllers:@[vc] animated:YES];
    [self presentViewController:navigationController1 animated:YES completion:nil];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

@end
