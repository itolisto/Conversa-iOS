//
//  LoginViewController.m
//  Conversa
//
//  Created by Edgar Gomez on 11/10/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "LoginViewController.h"

#import "Log.h"
#import "Colors.h"
#import "Account.h"
#import "Constants.h"
#import "Utilities.h"
#import "LoginHandler.h"
#import "UIStateButton.h"
#import "MBProgressHUD.h"
#import "JVFloatLabeledTextField.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *usernameTextField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIStateButton *signinButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) UITextField *activeTextField;

@end

@implementation LoginViewController

#pragma mark - Lifecycle Methods -

- (void)viewDidLoad {
    [super viewDidLoad];
    // Hide keyboard when pressed outside TextField
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    tap.delegate = self;
    // Add delegates
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    // Add login button properties
    [self.signinButton setBackgroundColor:[Colors green] forState:UIControlStateNormal];
    [self.signinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.signinButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    [self.signinButton setTitleColor:[Colors green] forState:UIControlStateHighlighted];
    // Init scroll state
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;

    if (self.activeTextField) {
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
        CGRect aRect = self.view.frame;
        aRect.size.height -= kbSize.height;

        if (!CGRectContainsPoint(aRect, self.activeTextField.frame.origin) ) {
            [self.scrollView scrollRectToVisible:self.activeTextField.frame animated:YES];
        }
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - IBAction Method -

- (IBAction)loginButtonPressed:(UIButton *)sender {
    [self doLogin];
}

- (IBAction)backBarButtonPressed:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate Methods -

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    if (textField == self.usernameTextField)
        [self.passwordTextField becomeFirstResponder];
    else
        [self doLogin];

    return YES;
}

#pragma mark - Login Methods -

- (BOOL)validForm {
    MBProgressHUD *hudError = [[MBProgressHUD alloc] initWithView:self.view];
    hudError.mode = MBProgressHUDModeText;
    [self.view addSubview:hudError];

    if(isEmailValid([self.usernameTextField text])) {
        if([self.passwordTextField hasText]) {
            [hudError removeFromSuperview];
            return YES;
        } else {
            hudError.label.text = NSLocalizedString(@"signup_password_length_error", nil);
            [hudError showAnimated:YES];
            [hudError hideAnimated:YES afterDelay:1.7];
            [self.passwordTextField becomeFirstResponder];
        }
    } else {
        hudError.label.text = NSLocalizedString(@"sign_email_not_valid_error", nil);
        [hudError showAnimated:YES];
        [hudError hideAnimated:YES afterDelay:1.7];
        [self.usernameTextField becomeFirstResponder];
    }

    return NO;
}

- (void)doLogin {
    if([self validForm]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        PFQuery *query = [Account query];
        [query whereKey:kUserEmailKey equalTo:self.usernameTextField.text];
        [query whereKey:kUserTypeKey equalTo:@(1)];
        [query selectKeys:@[kUserUsernameKey]];

        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if (error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self showErrorMessage];
            } else {
                [Account logInWithUsernameInBackground:((Account *)object).username
                                              password:self.passwordTextField.text
                                                 block:^(PFUser * _Nullable user, NSError * _Nullable error)
                 {
                     [MBProgressHUD hideHUDForView:self.view animated:YES];

                     if(user) {
                         // Successful login
                         [LoginHandler proccessLoginForAccount:[Account currentUser] fromViewController:self];
                     } else {
                         // The login failed. Check error to see why
                         [self showErrorMessage];
                     }
                 }];
            }
        }];
    }
}

- (void)showErrorMessage {
    UIAlertController * view = [UIAlertController
                                alertControllerWithTitle:nil
                                message:NSLocalizedString(@"sign_failed_message", nil)
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Ok"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action) {
                             [view dismissViewControllerAnimated:YES completion:nil];
                         }];
    [view addAction:ok];
    [self presentViewController:view animated:YES completion:nil];
}

@end
