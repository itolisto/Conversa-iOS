//
//  SearchViewController.m
//  Conversa
//
//  Created by Edgar Gomez on 29/01/16.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "SearchViewController.h"

#import "Log.h"
#import "Colors.h"
#import "Business.h"
#import "Constants.h"
#import "YapSearch.h"
#import "DatabaseView.h"
#import "ParseValidation.h"
#import "DatabaseManager.h"
#import "CustomSearchCell.h"
#import "NSFileManager+Conversa.h"
#import "CategoriesViewController.h"
#import "ProfileDialogViewController.h"

#import <YapDatabase/YapDatabaseView.h>
#import <DGActivityIndicatorView/DGActivityIndicatorView.h>

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *emptyInfoLabel;

@property (strong, nonatomic) DGActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) NSMutableArray<YapSearch *> *_mutableObjects;
@property (nonatomic, strong) NSString *searchWith;
@property (nonatomic, strong) YapDatabaseConnection *databaseConnection;
@property (nonatomic, strong) YapDatabaseViewMappings *recentMappings;

@property (assign, nonatomic) NSUInteger searchId;

@property (assign, nonatomic) NSInteger page;
@property (assign, nonatomic) BOOL loadingPage;
@property (assign, nonatomic) BOOL loadMore;

@end

@implementation SearchViewController

#pragma mark - Lifecycle Methods -

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self._mutableObjects = [NSMutableArray arrayWithCapacity:29];

    // Sets this view controller as presenting view controller for the search interface
    self.definesPresentationContext = YES;

    // Freeze our connection for use on the main-thread.
    // This gives us a stable data-source that won't change until we tell it to.
    self.databaseConnection = [[DatabaseManager sharedInstance] newConnection];
    self.databaseConnection.name = NSStringFromClass([self class]);
    [self.databaseConnection beginLongLivedReadTransaction];

    self.recentMappings = [[YapDatabaseViewMappings alloc] initWithGroups:@[RecentSearchGroup]
                                                                     view:RecentSearhDatabaseViewExtensionName];

    [self.databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        [self.recentMappings updateWithTransaction:transaction];
    }];

    self.activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeThreeDots tintColor:[UIColor greenColor] size:50.0f];
    self.activityIndicatorView.frame = CGRectMake(self.loadingView.frame.size.width  / 2 - 35,
                                             self.loadingView.frame.size.height / 2 - 35,
                                             70.0f,
                                             70.0f);
    [self.loadingView addSubview:self.activityIndicatorView];

    if ([self.recentMappings numberOfItemsInSection:0] > 0) {
        self.loadingView.hidden = YES;
        self.emptyView.hidden = YES;
        self.tableView.hidden = NO;
    } else {
        self.loadingView.hidden = YES;
        self.emptyView.hidden = NO;
        self.tableView.hidden = YES;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(yapDatabaseModified:)
                                                 name:YapDatabaseModifiedNotification
                                               object:[DatabaseManager sharedInstance].database];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.emptyView addGestureRecognizer:tap];

    // Remove extra lines
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:v];

    // Remove 1px bottom line
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init]
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YapDatabaseModifiedNotification object:[DatabaseManager sharedInstance].database];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:SEARCH_NOTIFICATION_NAME
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SEARCH_NOTIFICATION_NAME object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

- (void)dismissKeyboard {
    [((CategoriesViewController*)self.parentViewController).searchController.searchBar resignFirstResponder];
}

#pragma mark - Search Methods -

- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:SEARCH_NOTIFICATION_NAME]) {
        [self runQueryWithParameter:([notification.userInfo objectForKey:SEARCH_NOTIFICATION_DIC_KEY]) ? [notification.userInfo objectForKey:SEARCH_NOTIFICATION_DIC_KEY] : @""];
    }
}

- (void) runQueryWithParameter:(NSString *)search {
    self.searchId = arc4random_uniform(4294967294) + 1;

    if ([search length]) {
        [self._mutableObjects removeAllObjects];
        self.page = 0;
        self.loadingPage = NO;
        self.loadMore = YES;
        self.searchWith = [search copy];
        self.loadingView.hidden = NO;
        self.emptyView.hidden = YES;
        self.tableView.hidden = YES;
        [self searchBusiness];
    } else {
        [self clear];
    }
}

- (void)clear {
    self.searchWith = @"";

    if ([self.recentMappings numberOfItemsInSection:0] > 0) {
        self.loadingView.hidden = YES;
        self.emptyView.hidden = YES;
        self.tableView.hidden = NO;
    } else {
        self.loadingView.hidden = YES;
        self.emptyView.hidden = NO;
        self.tableView.hidden = YES;
    }

    [__mutableObjects removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - Data Methods -

- (void)searchBusiness {
    [self.activityIndicatorView startAnimating];
    
    [PFCloud callFunctionInBackground:@"searchBusiness"
                       withParameters:@{@"search": self.searchWith, @"skip": @(self.page), @"id": @(self.searchId)}
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
             self.emptyInfoLabel.text = NSLocalizedString(@"category_results_error", nil);
             self.emptyView.hidden = NO;
             self.tableView.hidden = YES;
             [ParseValidation validateError:error controller:self];
         } else {
             NSData *objectData = [json dataUsingEncoding:NSUTF8StringEncoding];
             NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:objectData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&error];

             if (error) {
                 self.emptyInfoLabel.text = NSLocalizedString(@"category_results_error", nil);
                 self.emptyView.hidden = NO;
                 self.tableView.hidden = YES;
                 [self._mutableObjects removeAllObjects];
             } else {
                 if ([[jsonDic objectForKey:@"id"] unsignedIntegerValue] == self.searchId) {
                     NSArray *results = [jsonDic valueForKeyPath:@"results"];
                     NSUInteger size = [results count];

                     for (int i = 0; i < size; i++) {
                         NSDictionary *object = [results objectAtIndex:i];
                         YapSearch *newSearch = [[YapSearch alloc] initWithUniqueId:[object objectForKey:@"oj"]];
                         newSearch.conversaId = [object objectForKey:@"id"];
                         newSearch.displayName = [object objectForKey:@"dn"];
                         newSearch.avatarUrl = [object objectForKey:@"av"];
                         newSearch.searchDate = [NSDate date];
                         [self._mutableObjects addObject:newSearch];
                     }

                     if (size > 0) {

                         if (size < 20) {
                             self.loadMore = NO;
                         }

                         if (self.page == 0) {
                             self.emptyView.hidden = YES;
                             self.tableView.hidden = NO;
                         }
                     } else {
                         if (self.page == 0) {
                             self.emptyInfoLabel.text = NSLocalizedString(@"category_results_empty", nil);
                             self.emptyView.hidden = NO;
                             self.tableView.hidden = YES;
                         }
                         self.loadMore = NO;
                     }

                     self.page++;
                 }
             }
         }

         [self.tableView reloadData];
     }];
}

- (NSArray<__kindof YapSearch *> *)objects {
    return __mutableObjects;
}

#pragma mark - UITableViewDataSource Methods -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.searchWith length] > 0) {
        if ([self.objects count] == indexPath.row + 1) {
            if (self.loadingPage) {
                return 30.0;
            }
        }
    }
    
    return 65.0;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if ([self.searchWith length] == 0) {
//        return NSLocalizedString(@"search_section_title_recents", nil);
//    }
//
//    return nil;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.searchWith length] == 0) {
        return [self.recentMappings numberOfItemsInSection:section];
    }

    return [self.objects count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.searchWith length] == 0) {
        return [self.recentMappings numberOfSections];
    }

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.searchWith length] > 0) {
        if ([self.objects count] == indexPath.row + 1) {
            if (self.loadingPage) {
                static NSString *CellIdentifier = @"CustomLoadCell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }

                return cell;
            }
        }
    }

    static NSString *simpleTableIdentifier = @"CustomSearchCell";
    CustomSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    if (cell == nil) {
        cell = [[CustomSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }

    // Configure the cell
    [cell configureCellWithYap:[self searchAtIndexPath:indexPath]];

    return cell;
}

#pragma mark - UITableViewDelegate Methods -

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *CellIdentifier = @"CustomCategoryHeaderCell";
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    UILabel *label = (UILabel *)[headerView viewWithTag:123];

    if ([self.searchWith length] == 0) {
        [label setText:NSLocalizedString(@"search_section_title_recents", nil)];
    } else {
        [label setText:NSLocalizedString(@"search_section_title_results", nil)];
    }

    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.loadMore) {
        if ([self.searchWith length] > 0) {
            if (!self.loadingPage && [self.objects count] == indexPath.row + 1) {
                self.loadingPage = YES;
                [self._mutableObjects addObject:[[YapSearch alloc] init]];
                [self.tableView reloadData];
                [self searchBusiness];
            }
        }
    }
}

#pragma mark - Navigation Method -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"FromSearchToProfile"]) {
        __block BOOL save = YES;
        __block YapSearch *business = ((CustomSearchCell*)sender).yapbusiness;
        YapDatabaseConnection *connection = [DatabaseManager sharedInstance].newConnection;

        [connection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
            YapSearch *search = [transaction objectForKey:business.uniqueId inCollection:[YapSearch collection]];

            if(search) {
                if ([self.searchWith length] > 0) {
                    if (![search.avatarUrl isEqualToString:business.avatarUrl]) {
                        search.avatarUrl = business.avatarUrl;
                    }
                }

                search.searchDate = [NSDate date];
                [search saveWithTransaction:transaction];
                save = NO;
            }
        } completionBlock:^{
            if (save) {
                business.searchDate = [NSDate date];
                [business saveNew:connection];
            }
        }];
        // Get reference to the destination view controller
        ProfileDialogViewController *destinationViewController = [segue destinationViewController];
        // Pass any objects to the view controller here, like...
        destinationViewController.yapbusiness = business;
        destinationViewController.enable = YES;
    }
}

#pragma mark - Find Method -

- (YapSearch *)searchAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.objects count] && indexPath.row < [self.objects count]) {
        return self.objects[indexPath.row];
    } else if (indexPath.row < [self.recentMappings numberOfItemsInAllGroups]) {
        __block YapSearch *search = nil;

        [self.databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            YapDatabaseViewTransaction *viewTransaction = [transaction ext:RecentSearhDatabaseViewExtensionName];
            NSUInteger row = indexPath.row;
            NSUInteger section = indexPath.section;

            NSAssert(row < [self.recentMappings numberOfItemsInSection:section], @"Cannot fetch search because row %d is >= numberOfItemsInSection %d", (int)row, (int)[self.recentMappings numberOfItemsInSection:section]);

            search = [viewTransaction objectAtRow:row inSection:section withMappings:self.recentMappings];
            NSParameterAssert(search != nil);
        }];
        
        return search;
    }

    return nil;
}

#pragma mark - YapDatabase Method -

- (void)yapDatabaseModified:(NSNotification *)notification
{
    // Jump to the most recent commit.
    // End & Re-Begin the long-lived transaction atomically.
    // Also grab all the notifications for all the commits that I jump.
    // If the UI is a bit backed up, I may jump multiple commits.
    NSArray *notifications  = [self.databaseConnection beginLongLivedReadTransaction];

    if ([notifications count] <= 0) {
        // Since we moved our databaseConnection to a new commit,
        // we need to update the mappings too.
        [self.databaseConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
            [self.recentMappings updateWithTransaction:transaction];
        }];
        return; // Already processed commit
    }

    // If the view isn't visible, we might decide to skip the UI animation stuff.
    if ([self.searchWith length]) {
        // Since we moved our databaseConnection to a new commit,
        // we need to update the mappings too.
        [self.databaseConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction){
            [self.recentMappings updateWithTransaction:transaction];
        }];
        return;
    }

    NSArray *recentRowChanges = nil;

    [[self.databaseConnection ext:RecentSearhDatabaseViewExtensionName] getSectionChanges:nil
                                                                               rowChanges:&recentRowChanges
                                                                         forNotifications:notifications
                                                                             withMappings:self.recentMappings];

    if([recentRowChanges count] == 0) {
        return;
    }

    // Familiar with NSFetchedResultsController?
    // Then this should look pretty familiar

    [self.tableView beginUpdates];

    for (YapDatabaseViewRowChange *rowChange in recentRowChanges)
    {
        switch (rowChange.type)
        {
            case YapDatabaseViewChangeDelete :
            {
                [self.tableView deleteRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeInsert :
            {
                [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeMove :
            {
                [self.tableView deleteRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeUpdate :
            {
                [self.tableView reloadRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }
    
    [self.tableView endUpdates];
}

@end
