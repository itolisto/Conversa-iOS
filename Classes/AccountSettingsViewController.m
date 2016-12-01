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
#import "Customer.h"
#import "YapSearch.h"
#import "Constants.h"
#import "YapContact.h"
#import "SettingsKeys.h"
#import "MBProgressHUD.h"
#import "DatabaseManager.h"
#import "NSFileManager+Conversa.h"
#import <Parse/Parse.h>
#import <IDMPhotoBrowser/IDMPhotoBrowser.h>

@interface AccountSettingsViewController ()

@property (weak, nonatomic) IBOutlet PFImageView *imageUser;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *displayNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UISwitch *sendReadSwitch;
@property (weak, nonatomic) IBOutlet UILabel *blockedContactsLabel;

@property (nonatomic, assign) BOOL reload;

@end

@implementation AccountSettingsViewController

#pragma mark - Lifecycle Methods -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Hide keyboard when pressed outside TextField
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = FALSE;
    [self.tableView addGestureRecognizer:tap];
    tap.delegate = self;
    
    // Imagen redonda
    self.imageUser.layer.cornerRadius = self.imageUser.frame.size.width / 2;
    self.imageUser.clipsToBounds = YES;
    self.imageUser.image = [UIImage imageNamed:@"ic_person"];
    // Agregar borde
    self.imageUser.layer.borderWidth = 3.0f;
    self.imageUser.layer.borderColor = [UIColor whiteColor].CGColor;
    // Datos iniciales
    self.emailTextField.text = [Account currentUser].email;
    self.displayNameTextField.text = [SettingsKeys getDisplayName];
    // Delegate
    self.emailTextField.delegate = self;
    self.usernameTextField.delegate = self;
    self.displayNameTextField.delegate = self;
    self.passwordTextField.delegate = self;

    self.blockedContactsLabel.text = @"Cargando";
    
    self.reload = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:BLOCK_NOTIFICATION_NAME
                                               object:nil];
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
    //self.displayNameTextField.text = [Account currentUser].displayName;
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
                                     message:@"El campo no puede quedar vacío"
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* change = [UIAlertAction
                                 actionWithTitle:@"Ok"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     if (textField == self.displayNameTextField) {
                                         //textField.text = [Account currentUser].displayName;
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
                                     message:@"¿Seguro que deseas cambiar tu contraseña?"
                                     preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction* change = [UIAlertAction
                                     actionWithTitle:@"Cambiar"
                                     style:UIAlertActionStyleDestructive
                                     handler:^(UIAlertAction * action) {
                                         Account *user = [Account currentUser];
                                         user.password = self.passwordTextField.text;
                                         
                                         MBProgressHUD *hudError = [[MBProgressHUD alloc] initWithView:self.view];
                                         hudError.mode = MBProgressHUDModeText;
                                         [self.view addSubview:hudError];
                                         
                                         [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                             if (succeeded && !error) {
                                                 hudError.labelText = @"Contraseña cambiada";
                                                 [hudError show:YES];
                                                 [hudError hide:YES afterDelay:1.7];
                                             } else {
                                                 hudError.labelText = @"Contraseña no se ha cambiado";
                                                 [hudError show:YES];
                                                 [hudError hide:YES afterDelay:1.7];
                                             }
                                             self.passwordTextField.text = @"";
                                         }];
                                     }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancelar"
                                 style:UIAlertActionStyleCancel
                                 handler:^(UIAlertAction * action) {
                                     self.passwordTextField.text = @"";
                                     [view dismissViewControllerAnimated:YES completion:nil];
                                 }];
        
        [view addAction:change];
        [view addAction:cancel];
        [self presentViewController:view animated:YES completion:nil];
    } else if (textField == self.displayNameTextField) {
//        Account *user = [Account currentUser];
//        
//        if (![textField.text isEqualToString:user.displayName]) {
//            NSString *temp = user.displayName;
//            user.displayName = self.displayNameTextField.text;
//            
//            MBProgressHUD *hudError = [[MBProgressHUD alloc] initWithView:self.view];
//            hudError.mode = MBProgressHUDModeText;
//            [self.view addSubview:hudError];
//            
//            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//                self.displayNameTextField.text = [Account currentUser].displayName;
//                
//                if (succeeded && !error) {
//                    hudError.labelText = @"Nombre cambiado";
//                    [hudError show:YES];
//                    [hudError hide:YES afterDelay:1.7];
//                } else {
//                    user.displayName = temp;
//                    [user saveInBackground];
//                    hudError.labelText = @"Nombre no se ha cambiado";
//                    [hudError show:YES];
//                    [hudError hide:YES afterDelay:1.7];
//                }
//            }];
//        }
    }
    
    return YES;
}

#pragma mark - UITableViewDelegate Methods -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 2) {
        if ([indexPath row] == 0) {
            [self cleanRecentSearches];
        }
    } else if([indexPath section] == 4) {
        [self showLogout];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 2) {
        if ([indexPath row] == 1) {
            __block NSUInteger count = 0;
            [[DatabaseManager sharedInstance].newConnection asyncReadWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
                [transaction enumerateRowsInCollection:[YapContact collection] usingBlock:^(NSString * _Nonnull key, id  _Nonnull object, id  _Nullable metadata, BOOL * _Nonnull stop) {
                    if (((YapContact*)object).blocked) {
                        count++;
                    }
                }];
            } completionBlock:^{
                if (count == 0) {
                    self.blockedContactsLabel.text = @"Ninguno";
                } else if (count == 1) {
                    self.blockedContactsLabel.text = @"1 contacto";
                } else {
                    self.blockedContactsLabel.text = [[NSString stringWithFormat:@"%lu", (unsigned long)count] stringByAppendingString:@" contactos"];
                }
            }];
            
            self.blockedContactsLabel.text = @"Cargando";
        }
    }
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark - UIImagePickerControllerDelegate Method -

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = compressImage(info[UIImagePickerControllerEditedImage]);

    if (image) {
        [self processImage:UIImageJPEGRepresentation(image, 0.5)];
    }

    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *) error contextInfo:(void *)contextInfo {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Error"
                              message: @"Hubo un error al guardar la imagen"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

//- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingItems:(NSArray *)items
//{
//    for (PHAsset *asset in items) {
//        PHImageManager *manager = [PHImageManager defaultManager];
//        [manager requestImageDataForAsset:asset
//                                  options:nil
//                            resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info)
//         {
//             if (imageData) {
//                 [self processImage:UIImageJPEGRepresentation(compressImage([UIImage imageWithData:imageData]), 0.5)];
//             }
//         }];
//    }
//    
//    [self dismissViewControllerAnimated:YES completion:NULL];
//}
//
//- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
//    [self dismissViewControllerAnimated:YES completion:NULL];
//}

- (void)processImage:(NSData *)picture {
    if (picture) {
        PFFile *filePicture = [PFFile fileWithName:@"avatar.jpg" data:picture];
        [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil) {
                 UIAlertController* view = [UIAlertController
                                            alertControllerWithTitle:nil
                                            message:nil
                                            preferredStyle:UIAlertControllerStyleAlert];
                 
                 UIAlertAction* ok = [UIAlertAction
                                      actionWithTitle:@"Ok"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          [view dismissViewControllerAnimated:YES completion:nil];
                                      }];
                 [view addAction:ok];
                 [self presentViewController:view animated:YES completion:nil];
             } else {
                 self.imageUser.image = [UIImage imageWithData:picture];
                 Account *account = [Account currentUser];
                 account[kUserAvatarKey] = filePicture;
                 [account saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                     if (!succeeded || error) {
                         [account saveEventually];
                     }
                 }];
                 // Save to Cache Directory
                 [[NSFileManager defaultManager] saveDataToCachesDirectory:picture
                                                                  withName:kAccountAvatarName
                                                              andDirectory:kMessageMediaImageLocation];
             }
         }];
    }
}

#pragma mark - Action Methods -

- (void)cleanRecentSearches {
    UIAlertController * view =   [UIAlertController
                                  alertControllerWithTitle:nil
                                  message:@"Limpia el historial de búsquedas recientes"
                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* clean = [UIAlertAction
                             actionWithTitle:@"Limpiar"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action) {
                                 [YapSearch clearAllRecentSearches];
                             }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancelar"
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
                             actionWithTitle:@"Cerrar sesión"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action) {
                                 [Account logOut];
                                 [view dismissViewControllerAnimated:YES completion:nil];
                                 UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                 UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
                                 [self presentViewController:viewController animated:YES completion:nil];
                             }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancelar"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action) {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    
    [view addAction:logout];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
}

- (IBAction)avatarButtonPressed:(UIButton *)sender {
    UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle:nil
                                 message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* viewPhotho = [UIAlertAction
                                 actionWithTitle:@"Ver imagen"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     //Do some thing here
                                     NSArray *photos = [IDMPhoto photosWithImages:@[self.imageUser.image]];
                                     IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos];
                                     browser.displayActionButton = NO;
                                     browser.displayArrowButton  = NO;
                                     browser.displayCounterLabel = NO;
                                     [self presentViewController:browser animated:YES completion:nil];
                                 }];
    UIAlertAction* photoLibrary = [UIAlertAction
                                   actionWithTitle:@"Librería"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       //Do some thing here
                                       PresentPhotoLibrary(self, YES, 1);
                                       [view dismissViewControllerAnimated:YES completion:nil];
                                   }];
    UIAlertAction* camera = [UIAlertAction
                             actionWithTitle:@"Cámara"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 //Do some thing here
                                 PresentPhotoCamera(self, YES);
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancelar"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action) {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    [view addAction:viewPhotho];
    [view addAction:photoLibrary];
    [view addAction:camera];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
}

- (IBAction)sendReadAction:(UISwitch *)sender {
    if (sender.on) {
        [SettingsKeys setAccountReadSetting:YES];
    } else {
        [SettingsKeys setAccountReadSetting:NO];
    }
}

@end
