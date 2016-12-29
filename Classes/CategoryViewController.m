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

#import <sys/sysctl.h>
#import <Parse/Parse.h>
#import <DGActivityIndicatorView/DGActivityIndicatorView.h>

@interface CategoryViewController()

@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *emptyInfoLabel;

@property (strong, nonatomic) DGActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) NSMutableArray<PFObject *> *_mutableObjects;
@property(strong, nonatomic) NSString *machine;
@property(nonatomic) BOOL visible;
@property NSInteger page;

@end

@implementation CategoryViewController

#pragma mark - Lifecycle Methods -

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self._mutableObjects = [NSMutableArray arrayWithCapacity:10];
    self.page = 0;

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

    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    self.machine = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];

    [self loadObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.barTintColor = [Colors greenNavbar];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [super viewWillAppear:animated];
}

#pragma mark - Data Methods -

- (void)clear {
    [__mutableObjects removeAllObjects];
    [self.tableView reloadData];
}

- (void)loadObjects {
    [self.activityIndicatorView startAnimating];

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

    [query setLimit:25];
    [query setSkip:self.page * 25];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self.activityIndicatorView stopAnimating];
        self.loadingView.hidden = YES;

        if (error) {
            self.emptyInfoLabel.text = NSLocalizedString(@"category_results_error", nil);
            self.emptyView.hidden = NO;
            [ParseValidation validateError:error controller:self];
        } else {
            if ([objects count] > 0) {
                self.tableView.hidden = NO;
                self.emptyView.hidden = YES;
                [self._mutableObjects addObjectsFromArray:objects];
                [self.tableView reloadData];
            } else {
                self.emptyInfoLabel.text = NSLocalizedString(@"category_results_empty", nil);
                self.emptyView.hidden = NO;
            }
        }
    }];
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.objects count] && indexPath.row < [self.objects count]) {
        return self.objects[indexPath.row];
    }

    return nil;
}

- (NSArray<__kindof PFObject *> *)objects {
    return __mutableObjects;
}

#pragma mark - UITableViewDataSource Methods -

// Return the number of rows in the section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.objects count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *object = [self objectAtIndexPath:indexPath];
    static NSString *CellIdentifier = @"CustomBusinessCell";
    CustomBusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[CustomBusinessCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    BusinessCategory *bs = (BusinessCategory *)object;

    // Configure the cell
    [cell configureCellWith:bs.business];

    return cell;
}

#pragma mark - UITableViewDelegate Methods -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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

#pragma mark - Navigation Method -

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
