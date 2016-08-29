//
//  ProfileViewController.m
//  Conversa
//
//  Created by Edgar Gomez on 3/5/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

#import "ProfileViewController.h"

#import "Colors.h"
#import "Account.h"
#import "Constants.h"
#import "YapContact.h"
#import "CustomInfoCell.h"
#import "DatabaseManager.h"
#import "CustomHeaderProfileCell.h"
#import "ConversationViewController.h"

@interface ProfileViewController ()
// Information
@property (strong, nonatomic) NSMutableDictionary *information;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.information = [[NSMutableDictionary alloc] initWithCapacity:6];
    
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    
    UINavigationItem *falsd = self.navigationItem;
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shareIcon"]];
    logo.frame = CGRectMake(0,0,24,24);
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareButtonPressed:)];
    singleTap.numberOfTapsRequired = 1;
    [logo setUserInteractionEnabled:YES];
    [logo addGestureRecognizer:singleTap];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:logo];
    falsd.rightBarButtonItem = rightButton;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backButtonPressed:)];
    falsd.leftBarButtonItem = backButton;
    
    self.navigationController.navigationBar.barTintColor = [Colors greenColor];
    
    [PFCloud callFunctionInBackground:@"profileInfo"
                       withParameters:@{@"business": self.business.objectId}
                                block:^(NSString * _Nullable result, NSError * _Nullable error)
     {
         if (!error) {
             id object = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:0
                                                           error:&error];
             if (error) {
                 // Error
             } else {
                 if ([object isKindOfClass:[NSDictionary class]]) {
                     NSDictionary *results = object;
                     self.information = [NSMutableDictionary dictionaryWithDictionary:[results copy]];
                     [self.tableView reloadData];
                 }
             }
         }
     }];
    
    // Remove extra lines
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:v];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [Colors greenColor];
}

- (IBAction)shareButtonPressed:(UIButton *)sender {
    
}

#pragma mark - UITableViewDataSource Methods -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] == 0) {
        return 220.0f;
    } else {
        return 60.0f;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.information count] == 0) {
        return 1;
    } else {
        NSMutableDictionary *fads = [self.information objectForKey:@"options"];
        return [fads count] + 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        static NSString *simpleTableIdentifier = @"CustomHeaderProfileCell";
        CustomHeaderProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier forIndexPath:indexPath];
        
        if (cell == nil) {
            cell = [[CustomHeaderProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        
        if ([self.information count] == 0) {
            [cell configureHeaderWith:self.business withGoChatEnable:self.enable];
        } else {
            [cell configureHeaderWith:self.information chatEnable:self.enable];
        }
        
        return cell;
    } else {
        static NSString *simpleTableIdentifier = @"CustomInfoCell";
        CustomInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier forIndexPath:indexPath];
        
        if (cell == nil) {
            cell = [[CustomInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        
        NSUInteger index = indexPath.row - 1;
        if (index >= [self.information count]) {
            index = [self.information count] - 1;
        }
        
        if ([self.information count] > 0) {
            [cell configureCellWith:[[self.information objectForKey:@"options"] objectAtIndex:index]];
        }
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate Methods -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation Method -

- (IBAction)backButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"FromProfileToChat"]) {
        __block YapContact *bs = nil;
        [[DatabaseManager sharedInstance].newConnection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
            bs = [transaction objectForKey:self.business.objectId inCollection:[YapContact collection]];
        }];
        // Get reference to the destination view controller
        ConversationViewController *destinationViewController = [segue destinationViewController];
        // Pass any objects to the view controller here, like...
        if (bs) {
            [destinationViewController initWithBuddy:bs];
        } else {
            [destinationViewController initWithBusiness:self.business];
        }
    }
}

@end
