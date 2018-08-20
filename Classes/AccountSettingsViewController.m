//
//  AccountSettingsViewController.m
//  Conversa
//
//  Created by Edgar Gomez on 12/10/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "AccountSettingsViewController.h"

#import "Image.h"
#import "Camera.h"
#import "Account.h"
#import "YapSearch.h"
#import "Constants.h"
#import "SettingsKeys.h"
#import "MBProgressHUD.h"
#import "DatabaseManager.h"
#import "NSFileManager+Conversa.h"

#import <IDMPhotoBrowser/IDMPhotoBrowser.h>

@interface AccountSettingsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *displayNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (nonatomic, assign) BOOL reload;

@end

@implementation AccountSettingsViewController

#pragma mark - Lifecycle Methods -

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    // Hide keyboard when pressed outside TextField
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = FALSE;
    [self.tableView addGestureRecognizer:tap];
    tap.delegate = self;

    // Datos iniciales
    self.emailTextField.text = [Account currentUser].email;
    self.displayNameTextField.text = [SettingsKeys getDisplayName];
    // Delegate
    self.displayNameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    self.reload = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:BLOCK_NOTIFICATION_NAME
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.reload) {
        self.reload = NO;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:2]]
                              withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BLOCK_NOTIFICATION_NAME object:nil];
}

- (void)dismissKeyboard {
    self.passwordTextField.text = @"";
    self.displayNameTextField.text = [SettingsKeys getDisplayName];
    [self.view endEditing:YES];
}

- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:BLOCK_NOTIFICATION_NAME]) {
        self.reload = YES;
    }
}

#pragma mark - UITextFieldDelegate Methods -

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if ([textField.text length] == 0) {
        UIAlertController * view=   [UIAlertController
                                     alertControllerWithTitle:nil
                                     message:NSLocalizedString(@"settings_account_alert_change_empty_title", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* change = [UIAlertAction
                                 actionWithTitle:@"Ok"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     if (textField == self.displayNameTextField) {
                                         textField.text = [SettingsKeys getDisplayName];
                                     }
                                     
                                     [view dismissViewControllerAnimated:YES completion:nil];
                                 }];
        [view addAction:change];
        [self presentViewController:view animated:YES completion:nil];
        return YES;
    }
    
    if (textField == self.passwordTextField) {
        UIAlertController * view=   [UIAlertController
                                     alertControllerWithTitle:nil
                                     message:NSLocalizedString(@"settings_account_alert_password_title", nil)
                                     preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction* change = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"settings_account_alert_password_action_change", nil)
                                     style:UIAlertActionStyleDestructive
                                     handler:^(UIAlertAction * action) {
                                         // TODO: Replace with networking layer
//                                         Account *user = [Account currentUser];
//                                         user.password = self.passwordTextField.text;
//                                         self.passwordTextField.text = @"";
//                                         [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//                                             MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//                                             hud.mode = MBProgressHUDModeCustomView;
//                                             hud.square = YES;
//                                             [hud.button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
//                                             UIImage *image;
//
//                                             if (error) {
//                                                 // Show notification
//                                                 image = [[UIImage imageNamed:@"ic_warning"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//                                                 hud.label.text = NSLocalizedString(@"settings_account_alert_password_not_changed", nil);
//                                             } else {
//                                                 // Show notification
//                                                 image = [[UIImage imageNamed:@"ic_checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//                                                 hud.label.text = NSLocalizedString(@"settings_account_alert_password_changed", nil);
//                                             }
//
//                                             hud.customView = [[UIImageView alloc] initWithImage:image];
//                                             [hud hideAnimated:YES afterDelay:2.f];
//                                         }];
                                     }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"common_action_cancel", nil)
                                 style:UIAlertActionStyleCancel
                                 handler:^(UIAlertAction * action) {
                                     self.passwordTextField.text = @"";
                                     [view dismissViewControllerAnimated:YES completion:nil];
                                 }];
        
        [view addAction:change];
        [view addAction:cancel];
        [self presentViewController:view animated:YES completion:nil];
    } else {
        if (![textField.text isEqualToString:[SettingsKeys getDisplayName]]) {
            NSString *temp = textField.text;
            // TODO: Replace with networking layer
//            [PFCloud callFunctionInBackground:@"updateCustomerName"
//                               withParameters:@{@"displayName" : temp, @"customerId" : [SettingsKeys getCustomerId]}
//                                        block:^(id  _Nullable object, NSError * _Nullable error)
//            {
//                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//                hud.mode = MBProgressHUDModeCustomView;
//                [hud.button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
//                hud.square = YES;
//                UIImage *image;
//
//                if (error) {
//                    self.displayNameTextField.text = [SettingsKeys getDisplayName];
//                    // Show notification
//                    image = [[UIImage imageNamed:@"ic_warning"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//                    hud.label.text = NSLocalizedString(@"settings_account_alert_displayname_not_changed", nil);
//                } else {
//                    // Change displayName
//                    [SettingsKeys setDisplayName:temp];
//                    // Show notification
//                    image = [[UIImage imageNamed:@"ic_checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//                    hud.label.text = NSLocalizedString(@"settings_account_alert_displayname_changed", nil);
//                }
//
//                hud.customView = [[UIImageView alloc] initWithImage:image];
//                [hud hideAnimated:YES afterDelay:2.f];
//            }];
        }
    }
    
    return YES;
}

#pragma mark - UITableViewDelegate Methods -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 1) {
        if ([indexPath row] == 0) {
            [self cleanRecentSearches];
        }
    } else if([indexPath section] == 2) {
        [self showLogout];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Action Methods -

- (void)cleanRecentSearches {
    UIAlertController * view =   [UIAlertController
                                  alertControllerWithTitle:nil
                                  message:NSLocalizedString(@"settings_account_recents_title", nil)
                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* clean = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"settings_account_recents_alert_action_clean", nil)
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action) {
                                 [YapSearch clearAllRecentSearches];
                             }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"common_action_cancel", nil)
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action) {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    
    [view addAction:clean];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
}

- (void)showLogout {
    UIAlertController * view =   [UIAlertController
                                  alertControllerWithTitle:nil
                                  message:nil
                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* logout = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"settings_account_logout_alert_action_logout", nil)
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action) {
                                 [Account logOut];
                                 //
                                 [view dismissViewControllerAnimated:YES completion:nil];
                                 UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                                 UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
                                 [self presentViewController:viewController animated:YES completion:nil];
                             }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"common_action_cancel", nil)
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action) {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    
    [view addAction:logout];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
}

@end
