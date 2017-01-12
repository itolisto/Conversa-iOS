//
//  CategoryViewController.m
//  Conversa
//
//  Created by Edgar Gomez on 12/14/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "CategoryViewController.h"

#import "Log.h"
#import "Colors.h"
#import "Constants.h"
#import "bCategory.h"
#import "Utilities.h"
#import "ParseValidation.h"
#import "BusinessCategory.h"
#import "CustomBusinessCell.h"
#import "ConversationViewController.h"
#import "ProfileDialogViewController.h"

#import <Parse/Parse.h>
#import <DGActivityIndicatorView/DGActivityIndicatorView.h>

@interface CategoryViewController()

@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *emptyInfoLabel;

@property (strong, nonatomic) DGActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) NSMutableArray<Business *> *_mutableObjects;
@property (assign, nonatomic) BOOL visible;

@property (assign, nonatomic) NSInteger page;
@property (assign, nonatomic) BOOL loadingPage;
@property (assign, nonatomic) BOOL loadMore;

@end

@implementation CategoryViewController

#pragma mark - Lifecycle Methods -

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self._mutableObjects = [NSMutableArray arrayWithCapacity:10];
    self.page = 0;
    self.loadingPage = NO;
    self.loadMore = YES;

    self.tableView.hidden = YES;
    self.emptyView.hidden = YES;

    self.activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeThreeDots tintColor:[UIColor greenColor] size:50.0f];
    self.activityIndicatorView.frame = CGRectMake((self.loadingView.frame.size.width/2) - 35,
                                             (self.loadingView.frame.size.height/2) - 35,
                                             70.0f,
                                             70.0f);
    [self.loadingView addSubview:self.activityIndicatorView];

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // Remove extra lines
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [UIColor whiteColor];
    [self.tableView setTableFooterView:v];

    [self loadObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.backItem.title = @"";
    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationController.navigationBar.barTintColor = [Colors greenNavbar];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

#pragma mark - Data Methods -

- (void)loadObjects {
    if (self.page == 0) {
        [self.activityIndicatorView startAnimating];
    }

    PFQuery *query = [BusinessCategory query];
    [query selectKeys:@[kBusinessCategoryBusinessKey]];

    [query includeKey:kBusinessCategoryBusinessKey];
    [query whereKey:kBusinessCategoryCategoryKey equalTo:[bCategory objectWithoutDataWithObjectId:self.categoryId]];
    [query whereKey:kBusinessCategoryActiveKey   equalTo:@(YES)];

    PFQuery *param1 = [Business query];
    [param1 selectKeys:@[kBusinessDisplayNameKey, kBusinessAboutKey, kBusinessAvatarKey, kBusinessConversaIdKey, kBusinessVerifiedKey]];
    [param1 whereKey:kBusinessActiveKey  equalTo:@(YES)];
    [param1 whereKey:kBusinessCountryKey equalTo:[PFObject objectWithoutDataWithClassName:@"Country" objectId:@"QZ31UNerIj"]];
    [param1 whereKeyDoesNotExist:kBusinessBusinessKey];

    [query whereKey:kBusinessCategoryBusinessKey matchesKey:kObjectRowObjectIdKey inQuery:param1];

    [query orderByAscending:kBusinessCategoryRelevanceKey];
    [query addAscendingOrder:kBusinessCategoryPositionKey];

    [query setLimit:20];
    [query setSkip:self.page * 20];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (self.page == 0) {
            [self.activityIndicatorView stopAnimating];
            self.loadingView.hidden = YES;
        }

        if (self.loadingPage) {
            self.loadingPage = NO;
            [self._mutableObjects removeLastObject];
        }

        if (error) {
            self.emptyInfoLabel.text = NSLocalizedString(@"category_results_error", nil);
            self.emptyView.hidden = NO;
            self.loadMore = NO;
            if ([ParseValidation validateError:error]) {
                [ParseValidation _handleInvalidSessionTokenError:self];
            }
        } else {
            NSUInteger size = [objects count];

            if (size > 0) {
                NSMutableArray <Business*> *business = [NSMutableArray arrayWithCapacity:size];

                for (int i = 0; i < size; i++) {
                    [business addObject:((BusinessCategory*)[objects objectAtIndex:i]).business];
                }

                if (size < 20) {
                    self.loadMore = NO;
                }

                [self._mutableObjects addObjectsFromArray:business];

                if (self.page == 0) {
                    self.tableView.hidden = NO;
                    self.emptyView.hidden = YES;
                }
            } else {
                if (self.page == 0) {
                    self.emptyInfoLabel.text = NSLocalizedString(@"category_results_empty", nil);
                    self.emptyView.hidden = NO;
                }
                self.loadMore = NO;
            }

            self.page++;
        }

        [self.tableView reloadData];
    }];
}

- (Business *)objectAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.objects count] && indexPath.row < [self.objects count]) {
        return self.objects[indexPath.row];
    }

    return nil;
}

- (NSArray<__kindof Business *> *)objects {
    return __mutableObjects;
}

#pragma mark - UITableViewDataSource Methods -

// Return the number of rows in the section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.objects count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.objects count] == indexPath.row + 1) {
        if (self.loadingPage) {
            return 30.0;
        }
    }

    return 65.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;

    if ([self.objects count] == indexPath.row + 1) {
        if (self.loadingPage) {
            CellIdentifier = @"CustomLoadCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            return cell;
        }
    }

    CellIdentifier = @"CustomBusinessCell";
    CustomBusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[CustomBusinessCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    // Configure the cell
    [cell configureCellWith:[self objectAtIndexPath:indexPath]];

    return cell;
}

#pragma mark - UITableViewDelegate Methods -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.loadMore) {
        if (!self.loadingPage && [self.objects count] == indexPath.row + 1) {
            self.loadingPage = YES;
            [self._mutableObjects addObject:[Business object]];
            [self.tableView reloadData];
            [self loadObjects];
        }
    }
}

#pragma mark - Navigation Method -

//- (void)backPressed {
//    [self.navigationController popViewControllerAnimated:YES];
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"FromCategoryToProfile"]) {
        // Get reference to the destination view controller
        ProfileDialogViewController *destinationViewController = [segue destinationViewController];
        // Pass any objects to the view controller here, like...
        destinationViewController.business = ((BusinessCategory*)sender).business;
        destinationViewController.enable = YES;
    }
}

@end
