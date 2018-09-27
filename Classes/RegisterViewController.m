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
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *termsPrivacyLabel;
@property (weak, nonatomic) UITextField *activeTextField;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (assign, nonatomic) double birthdayTimestamp;

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

    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:self.termsPrivacyLabel.text
                                                                                attributes:nil];

    NSString *language = [[[NSLocale preferredLanguages] objectAtIndex:0] substringToIndex:2];
    NSRange start, startPrivacy;

    if ([language isEqualToString:@"es"]) {
        start = [self.termsPrivacyLabel.text rangeOfString:@"TÉRMINOS"];
        startPrivacy = NSMakeRange([self.termsPrivacyLabel.text rangeOfString:@"POLÍTICAS"].location, 23);
    } else {
        start = [self.termsPrivacyLabel.text rangeOfString:@"TERMS"];
        startPrivacy = NSMakeRange([self.termsPrivacyLabel.text rangeOfString:@"PRIVACY"].location, 16);
    }

    // Rest of Text normal
    [attrStr setAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}
                     range:NSMakeRange(0, start.location)];
    // Only "Y" (es) or "AND" (en) need a range because is in the middle
    [attrStr setAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}
                     range:NSMakeRange(start.location + start.length, ([language isEqualToString:@"es"]) ? 3 : 5)];
    // Green
    [attrStr setAttributes:@{NSForegroundColorAttributeName:[Colors green]}
                     range:start];
    [attrStr setAttributes:@{NSForegroundColorAttributeName:[Colors green]}
                     range:startPrivacy];

    self.termsPrivacyLabel.activeLinkAttributes = @{NSForegroundColorAttributeName:[UIColor lightGrayColor]};
    self.termsPrivacyLabel.linkAttributes = @{NSForegroundColorAttributeName: [Colors green],
                                              NSUnderlineStyleAttributeName: [NSNumber numberWithBool:NO]
                                              };

    NSURL *url = [NSURL URLWithString:@"http://conversachat.com/terms"];
    NSURL *urlPrivacy = [NSURL URLWithString:@"http://conversachat.com/privacy"];

    self.termsPrivacyLabel.attributedText = attrStr;

    [self.termsPrivacyLabel addLinkToURL:url withRange:start];
    [self.termsPrivacyLabel addLinkToURL:urlPrivacy withRange:startPrivacy];

    self.termsPrivacyLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    self.termsPrivacyLabel.delegate = self;
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    SFSafariViewController *svc = [[SFSafariViewController alloc]initWithURL:url
                                                     entersReaderIfAvailable:NO];
    svc.delegate = self;
    [self presentViewController:svc animated:YES completion:nil];
}

#pragma mark - UIGestureRecognizerDelegate Method -

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return ![touch.view isKindOfClass:[TTTAttributedLabel class]];
}

#pragma mark - Observer Methods -

- (void) dismissKeyboard {
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
            [hudError.button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
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
            [hudError.button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
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
    // We multiply as Date in Javascript uses milliseconds
    self.birthdayTimestamp = [sender.date timeIntervalSince1970] * 1000;
}

- (void)doRegister {
    // TODO: Replace with networking layer
//    Account *user = [Account object];
//    user.username = self.emailTextField.text;
//    user.email = self.emailTextField.text;
//    user.password = self.passwordTextField.text;
//    // Extra fields
//    user[kUserTypeKey] = @(1);
//    if (self.birthdayTimestamp) {
//        user[kUserCustomerBirthdayKey] = @(self.birthdayTimestamp);
//    } else {
//        user[kUserCustomerBirthdayKey] = @(3661000);
//    }
//    user[kUserCustomerGenderKey] = @([self.genderControl selectedSegmentIndex]);
//
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud.button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
//
//    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [hud hideAnimated:YES];
//        if (error) {
//            if (error.code == kPFErrorUserEmailTaken || error.code == kPFErrorUsernameTaken) {
//                [self showErrorMessage:NSLocalizedString(@"signup_email_error", nil)];
//            } else {
//                [self showErrorMessage:NSLocalizedString(@"signup_complete_error", nil)];
//            }
//        } else {
//            [LoginHandler proccessLoginForAccount:[Account currentUser] fromViewController:self];
//        }
//    }];
}

- (void)showErrorMessage:(NSString*)message {
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
