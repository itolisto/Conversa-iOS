//
//  AboutViewController.m
//  Conversa
//
//  Created by Edgar Gomez on 2/28/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

#import "AboutViewController.h"

#import "Account.h"
#import "YapContact.h"
#import "MBProgressHUD.h"
#import "DatabaseManager.h"
#import "ParseValidation.h"
#import "ProfileDialogViewController.h"
@import Parse;

@interface AboutViewController ()

@property(nonatomic, strong) MBProgressHUD *hud;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    // Remove extra lines
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:v];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.hud) {
        [self.hud hideAnimated:YES];
    }
    [super viewWillDisappear:animated];
}

#pragma mark - SFSafariViewControllerDelegate Methods -

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate Methods -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        // Support
        [self callForId:@"1"];
    } else if (indexPath.row == 1) {
        // Conversa Agent
        [self callForId:@"2"];
    } else {
        // Terms & Privacy
        SFSafariViewController *svc = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"http://conversachat.com/terms"] entersReaderIfAvailable:NO];
        svc.delegate = self;
        [self presentViewController:svc animated:YES completion:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)callForId:(NSString*)purpose {
    self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    //self.hud.square = YES;
    if ([purpose isEqualToString:@"1"]) {
        self.hud.label.text = NSLocalizedString(@"sett_help_dialog_support_message", nil);
    } else {
        self.hud.label.text = NSLocalizedString(@"sett_help_dialog_agent_message", nil);
    }
    [self.hud showAnimated:YES];

    __weak typeof(self) wself = self;

    [PFCloud callFunctionInBackground:@"getConversaAccountId"
                       withParameters:@{@"customer": @(1), @"purpose": @([purpose intValue])}
                                block:^(NSString *  _Nullable objectId, NSError * _Nullable error)
    {
        typeof(self)sSelf = wself;

        if (sSelf) {
            if (error) {
                if ([ParseValidation validateError:error]) {
                    [ParseValidation _handleInvalidSessionTokenError:[sSelf topViewController]];
                } else {
                    [sSelf.hud hideAnimated:YES];
                    [sSelf showError];
                }
            } else {
                __block YapContact *contact;
                [[DatabaseManager sharedInstance].newConnection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
                    [YapContact fetchObjectWithUniqueID:objectId transaction:transaction];
                }];

                if (contact) {
                    // Go to profile
                    [sSelf showProfileFor:contact];
                } else {
                    [sSelf callForAccount:objectId];
                }
            }
        }
    }];
}

- (void)callForAccount:(NSString*)accountId {
    __weak typeof(self) wself = self;

    [PFCloud callFunctionInBackground:@"getConversaAccount"
                       withParameters:@{@"accountId": accountId}
                                block:^(NSString *  _Nullable jsonData, NSError * _Nullable error)
     {
         typeof(self)sSelf = wself;

         if (sSelf) {
             [sSelf.hud hideAnimated:YES];
             
             if (error) {
                 if ([ParseValidation validateError:error]) {
                     [ParseValidation _handleInvalidSessionTokenError:[sSelf topViewController]];
                 } else {
                     [sSelf showError];
                 }
             } else {
                 NSDictionary *results = [NSJSONSerialization JSONObjectWithData:[jsonData dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:0
                                                               error:&error];

                 YapContact *newBuddy = [[YapContact alloc] initWithUniqueId:[results objectForKey:@"oj"]];
                 newBuddy.accountUniqueId = [Account currentUser].objectId;
                 newBuddy.displayName = [results objectForKey:@"dn"];
                 newBuddy.conversaId = [results objectForKey:@"id"];
                 newBuddy.avatarThumbFileId = [results objectForKey:@"av"];
                 newBuddy.composingMessageString = @"";
                 newBuddy.blocked = NO;
                 newBuddy.mute = NO;
                 // Go to profile
                 [sSelf showProfileFor:newBuddy];
             }
         }
     }];
}

- (void)showProfileFor:(YapContact*)contact {
    if (self.isViewLoaded && self.view.window) {
        // Get reference to the destination view controller
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ProfileDialogViewController *destinationViewController = [storyboard instantiateViewControllerWithIdentifier:@"profileViewController"];

        destinationViewController.objectId = contact.uniqueId;
        destinationViewController.avatarUrl = contact.avatarThumbFileId;
        destinationViewController.displayName = contact.displayName;
        destinationViewController.conversaID = contact.conversaId;
        destinationViewController.enable = YES;

        UIViewController *controller = [self topViewController];

        if (controller) {
            if ([controller isKindOfClass:[UITabBarController class]]) {
                UITabBarController *tbcontroller = (UITabBarController*)controller;
                UIViewController *scontroller = [tbcontroller selectedViewController];

                if ([scontroller isKindOfClass:[UINavigationController class]]) {
                    UINavigationController *navcontroller = (UINavigationController*)scontroller;

                    if (navcontroller.isNavigationBarHidden) {
                        navcontroller.navigationBarHidden = NO;
                    }

                    [navcontroller presentViewController:destinationViewController
                                                animated:YES
                                              completion:nil];
                } else {
                    // scontroller is a uiviewcontroller
                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:scontroller];

                    [navController presentViewController:destinationViewController
                                                animated:YES
                                              completion:nil];
                }
            } else if ([controller isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navcontroller = (UINavigationController*)controller;
                [navcontroller presentViewController:destinationViewController
                                            animated:YES
                                          completion:nil];
            } else {
                if (controller.navigationController) {
                    [controller.navigationController presentViewController:destinationViewController
                                                                  animated:YES
                                                                completion:nil];
                } else {
                    // Create UINavigationController if not exists
                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
                    
                    [navController presentViewController:destinationViewController
                                                animated:YES
                                              completion:nil];
                }
            }
        }
    }
}

- (void)showError {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    //hud.square = YES;
    hud.detailsLabel.text = NSLocalizedString(@"sett_help_dialog_message_error", nil);
    [hud hideAnimated:YES afterDelay:2.f];
}

@end
