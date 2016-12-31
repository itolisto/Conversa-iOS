//
//  RegisterViewController.m
//  Conversa
//
//  Created by Edgar Gomez on 11/10/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "RegisterViewController.h"

#import "Log.h"
#import "Colors.h"
#import "Account.h"
#import "Customer.h"
#import "Constants.h"
#import "Utilities.h"
#import "LoginHandler.h"
#import "UIStateButton.h"
#import "MBProgressHUD.h"
#import "JVFloatLabeledTextField.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *emailTextField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderControl;
@property (weak, nonatomic) IBOutlet UIStateButton *signupButton;
@property (weak, nonatomic) UITextField *activeTextField;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation RegisterViewController

#pragma mark - Lifecycle Methods -

- (void)viewDidLoad {
    [super viewDidLoad];
    // Hide keyboard when pressed outside TextField
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    tap.delegate = self;
    // Add login button properties
    [self.signupButton setBackgroundColor:[Colors green] forState:UIControlStateNormal];
    [self.signupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.signupButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    [self.signupButton setTitleColor:[Colors green] forState:UIControlStateHighlighted];
    // Add delegates
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.birthdayTextField.delegate = self;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker setMaximumDate:[NSDate date]];
    [datePicker addTarget:self action:@selector(updateTextField:)
         forControlEvents:UIControlEventValueChanged];

    [self.birthdayTextField setInputView:datePicker];
}

#pragma mark - Observer Methods -

- (void) dismissKeyboard {
    //Causes the view (or one of its embedded text fields) to resign the first responder status.
    [self.view endEditing:YES];
}

-(void)resignKeyboard {
    [self.birthdayTextField resignFirstResponder];
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
    
    if ([self.birthdayTextField isFirstResponder]) {
        if ([self.birthdayTextField inputAccessoryView] == nil) {
            UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, kbSize.height, self.view.frame.size.width, 44)] ;
            [keyboardToolbar setBarStyle:UIBarStyleBlack];
            [keyboardToolbar setTranslucent:YES];
            [keyboardToolbar sizeToFit];
            UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                        target:self
                                                                                        action:nil];
            UIBarButtonItem *doneButton1 =[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"common_action_done", nil)
                                                                           style:UIBarButtonItemStyleDone
                                                                          target:self
                                                                          action:@selector(resignKeyboard)];

            NSArray *itemsArray = [NSArray arrayWithObjects:flexButton,doneButton1, nil];
            [keyboardToolbar setItems:itemsArray];
            [self.birthdayTextField setInputAccessoryView:keyboardToolbar];
            [self.birthdayTextField reloadInputViews];
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

#pragma mark - Action Methods -

- (IBAction)closeButtonPressed:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)registerButtonPressed:(UIButton *)sender {
    if ([self validateTextField:self.emailTextField text:self.emailTextField.text select:YES] &&
        [self validateTextField:self.passwordTextField text:self.passwordTextField.text select:YES])
    {
        [self doRegister];
    }
}

#pragma mark - UITextFieldDelegate Method -

- (BOOL)validateTextField:(JVFloatLabeledTextField*)textField text:(NSString*)text select:(BOOL)select {
    if (textField == self.emailTextField) {
        if (isEmailValid(text)) {
            return YES;
        } else {
            MBProgressHUD *hudError = [[MBProgressHUD alloc] initWithView:self.view];
            hudError.mode = MBProgressHUDModeText;
            [self.view addSubview:hudError];

            if ([text isEqualToString:@""]) {
                hudError.label.text = NSLocalizedString(@"common_field_required", nil);
            } else {
                hudError.label.text = NSLocalizedString(@"common_field_invalid", nil);
            }

            [hudError showAnimated:YES];
            [hudError hideAnimated:YES afterDelay:1.7];

            if (select) {
                if (![textField isFirstResponder]) {
                    [textField becomeFirstResponder];
                }
            }

            return NO;
        }
    } else {
        if ([text isEqualToString:@""]) {
            MBProgressHUD *hudError = [[MBProgressHUD alloc] initWithView:self.view];
            hudError.mode = MBProgressHUDModeText;
            [self.view addSubview:hudError];
            hudError.label.text = NSLocalizedString(@"common_field_required", nil);
            [hudError showAnimated:YES];
            [hudError hideAnimated:YES afterDelay:1.7];

            if (select) {
                if (![textField isFirstResponder]) {
                    [textField becomeFirstResponder];
                }
            }

            return NO;
        } else {
            return YES;
        }
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeTextField = nil;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self.birthdayTextField becomeFirstResponder];
    }
    
    return YES;
}

#pragma mark - Register Methods -

-(void)updateTextField:(UIDatePicker *)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    self.birthdayTextField.text = [dateFormatter stringFromDate:sender.date];
    [self.birthdayTextField resignFirstResponder];
}

- (void) doRegister {
    Account *user = [Account object];
    NSArray *emailPieces = [self.emailTextField.text componentsSeparatedByString: @"@"];
    user.username = [emailPieces objectAtIndex: 0];
    user.email = self.emailTextField.text;
    user.password = self.passwordTextField.text;
    // Extra fields
    user[kUserTypeKey] = @(1);
    user[kUserCustomerBirthdayKey] = self.birthdayTextField.text;
    user[kUserCustomerGenderKey] = @([self.genderControl selectedSegmentIndex]);

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error) {
            if (error.code == kPFErrorUserEmailTaken) {
                [self showErrorMessage:NSLocalizedString(@"signup_email_error", nil)];
            } else {
                [self showErrorMessage:NSLocalizedString(@"signup_complete_error", nil)];
            }
        } else {
            [LoginHandler proccessLoginForAccount:[Account currentUser] fromViewController:self];
        }
    }];
}

- (void) showErrorMessage:(NSString*)message {
    UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle:nil
                                 message:message
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
