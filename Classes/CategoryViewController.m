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
#import "Utilities.h"
#import "ParseValidation.h"
#import "CustomSearchCell.h"
#import "BusinessCategory.h"
#import "ConversationViewController.h"
#import "ProfileDialogViewController.h"
#import "MZFormSheetPresentationViewController.h"
#import <sys/sysctl.h>

@interface CategoryViewController()

@property (strong, nonatomic) NSMutableArray<PFObject *> *_mutableObjects;
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

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
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomSearchCell" bundle:nil] forCellReuseIdentifier:@"CustomSearchCell"];
    
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

#pragma mark - PFQueryTableViewController Methods -

- (void)clear {
    [__mutableObjects removeAllObjects];
    [self.tableView reloadData];
}

- (void)loadObjects {
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

    [query setLimit:25];
    [query setSkip:self.page * 25];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            [ParseValidation validateError:error controller:self];
        }

        [self._mutableObjects addObjectsFromArray:objects];
        [self.tableView reloadData];
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
    [ProfileDialogViewController controller:self
                                   business:((BusinessCategory*) [self objectAtIndexPath:indexPath]).business
                                     enable:YES
                                     device:self.machine];
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

@end
