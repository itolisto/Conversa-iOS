//
//  CategoryViewController.m
//  Conversa
//
//  Created by Edgar Gomez on 12/14/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "CategoryViewController.h"

#import "Log.h"
#import "Flurry.h"
#import "Colors.h"
#import "Account.h"
#import "Constants.h"
#import "Utilities.h"
#import "ParseValidation.h"
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
@property (strong, nonatomic) NSMutableArray<YapContact *> *_mutableObjects;
@property (assign, nonatomic) BOOL visible;

@property (assign, nonatomic) NSInteger page;
@property (assign, nonatomic) BOOL loadingPage;
@property (assign, nonatomic) BOOL loadMore;

@end

@implementation CategoryViewController

#pragma mark - Lifecycle Methods -

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.navigationController.automaticallyAdjustsScrollViewInsets = NO;
//    self.extendedLayoutIncludesOpaqueBars = YES;
//    self.navigationController.navigationBar.barTintColor = [Colors greenNavbar];
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    if (@available(iOS 11.0, *)) {
//        [self.searchController.searchBar.heightAnchor constraintLessThanOrEqualToConstant: 48].active = YES;
//    }

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
    
    // Remove extra lines
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [UIColor whiteColor];
    [self.tableView setTableFooterView:v];

    [self loadObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [Colors greenNavbar];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

#pragma mark - Data Methods -

- (void)loadObjects {
    if (self.page == 0) {
        [self.activityIndicatorView startAnimating];
    }

    [PFCloud callFunctionInBackground:@"getCategoryBusinesses"
                       withParameters:@{@"page": @(self.page), @"categoryId": self.categoryId, @"custom": @(self.custom)}
                                block:^(NSString *json, NSError *error)
     {
         if (self.page == 0) {
             [self.activityIndicatorView stopAnimating];
             self.loadingView.hidden = YES;
         }

         if (self.loadingPage) {
             self.loadingPage = NO;
             [self._mutableObjects removeLastObject];
         }

         if (error) {
             if ([ParseValidation validateError:error]) {
                 [ParseValidation _handleInvalidSessionTokenError:self];
             } else {
                 self.emptyInfoLabel.text = NSLocalizedString(@"category_results_error", nil);
                 self.emptyView.hidden = NO;
                 self.loadMore = NO;
             }
         } else {
             NSData *objectData = [json dataUsingEncoding:NSUTF8StringEncoding];
             NSArray *results = [NSJSONSerialization JSONObjectWithData:objectData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];

             if (error) {
                 self.emptyInfoLabel.text = NSLocalizedString(@"category_results_error", nil);
                 self.emptyView.hidden = NO;
                 self.loadMore = NO;
             } else {
                 NSUInteger size = [results count];

                 if (size > 0) {
                     NSMutableArray <YapContact*> *businesses = [NSMutableArray arrayWithCapacity:size];

                     for (int i = 0; i < size; i++) {
                         NSDictionary *business = [results objectAtIndex:i];

                         YapContact *newBuddy = [[YapContact alloc] initWithUniqueId:[business valueForKey:@"ob"]];
                         newBuddy.accountUniqueId = [Account currentUser].objectId;
                         newBuddy.displayName = [business valueForKey:@"dn"];
                         newBuddy.conversaId = [business valueForKey:@"cn"];

                         if ([business valueForKey:@"av"]) {
                             newBuddy.avatarThumbFileId = [business valueForKey:@"av"];
                         }
                         [businesses addObject:newBuddy];
                     }

                     if (size < 20) {
                         self.loadMore = NO;
                     }

                     [self._mutableObjects addObjectsFromArray:businesses];

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
         }
         
         [self.tableView reloadData];
     }];
}

- (YapContact *)objectAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.objects count] && indexPath.row < [self.objects count]) {
        return self.objects[indexPath.row];
    }

    return nil;
}

- (NSArray<__kindof YapContact *> *)objects {
    return __mutableObjects;
}

#pragma mark - UITableViewDataSource Methods -

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
            [self._mutableObjects addObject:[[YapContact alloc] init]];
            [self.tableView reloadData];
            [self loadObjects];
        }
    }
}

#pragma mark - Navigation Method -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"FromCategoryToProfile"]) {
        // Get reference to the destination view controller
        ProfileDialogViewController *destinationViewController = [segue destinationViewController];
        // Pass any objects to the view controller here, like...
        YapContact *business = ((CustomBusinessCell*)sender).business;
        destinationViewController.objectId = business.uniqueId;
        destinationViewController.avatarUrl = business.avatarThumbFileId;
        destinationViewController.displayName = business.displayName;
        destinationViewController.conversaID = business.conversaId;
        destinationViewController.enable = YES;
        [Flurry logEvent:@"user_profile_open" withParameters:@{@"fromCategory": @(YES)}];
    }
}

@end
