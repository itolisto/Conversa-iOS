//
//  ProfileDialogViewController.m
//  Conversa
//
//  Created by Edgar Gomez on 11/28/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

#import "ProfileDialogViewController.h"

#import "Log.h"
#import "Colors.h"
#import "AppJobs.h"
#import "Account.h"
#import "Business.h"
#import "YapSearch.h"
#import "Constants.h"
#import "YapContact.h"
#import "DatabaseManager.h"
#import "ParseValidation.h"
#import "BranchLinkProperties.h"
#import "BranchUniversalObject.h"
#import "NSFileManager+Conversa.h"
#import "ConversationViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface ProfileDialogViewController ()

@property (assign, nonatomic, getter=isSelected) BOOL select;
@property (assign, nonatomic) NSUInteger followers;
@property (strong, nonatomic) NSString* businessId;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UIView *statusView;

@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *conversaIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;

@property (weak, nonatomic) IBOutlet UIImageView *headerImage;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteImageView;
@property (weak, nonatomic) IBOutlet UIImageView *chatImageView;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;

@property (strong, nonatomic) UITapGestureRecognizer* tapOutsideRecognizer;

@end

/*
 * Storyboard implementation information in 
 * http://stackoverflow.com/questions/11236367/display-clearcolor-uiviewcontroller-over-uiviewcontroller
 */

@implementation ProfileDialogViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.containerView.layer.cornerRadius = 10.0f;
    self.containerView.layer.masksToBounds = YES;

    self.avatarImage.backgroundColor = [UIColor clearColor];
    self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.width / 2;

    // Agregar borde
    self.statusView.layer.borderWidth = 2.0f;
    self.statusView.layer.borderColor = [Colors white].CGColor;
    self.statusView.layer.cornerRadius = self.statusView.frame.size.width / 2;

    if (self.business) {
        self.businessId = self.business.objectId;

        @try {
            if ([self.business avatar]) {
                [self.avatarImage sd_setImageWithURL:[NSURL URLWithString:[[self.business avatar] url]]
                                    placeholderImage:[UIImage imageNamed:@"ic_business_default"]];
            } else {
                self.avatarImage.image = [UIImage imageNamed:@"ic_business_default"];
            }
        } @catch (NSException *exception) {
            self.avatarImage.image = [UIImage imageNamed:@"ic_business_default"];
        } @catch (id exception) {
            self.avatarImage.image = [UIImage imageNamed:@"ic_business_default"];
        }

        self.displayNameLabel.text = self.business.displayName;
        self.conversaIdLabel.text = [@"@" stringByAppendingString:self.business.conversaID];
    } else {
        self.businessId = self.yapbusiness.uniqueId;

        if ([self.yapbusiness.avatarUrl length] > 0) {
            [self.avatarImage sd_setImageWithURL:[NSURL URLWithString:self.yapbusiness.avatarUrl]
                                placeholderImage:[UIImage imageNamed:@"ic_business_default"]];
        } else {
            self.avatarImage.image = [UIImage imageNamed:@"ic_business_default"];
        }

        self.displayNameLabel.text = self.yapbusiness.displayName;
        self.conversaIdLabel.text = [@"@" stringByAppendingString:self.yapbusiness.conversaId];
    }

    self.select = NO;
    self.favoriteButton.enabled = NO;
    self.favoriteImageView.image = [UIImage imageNamed:@"ic_fav_not"];

    if (!_enable) {
        self.chatButton.enabled = NO;
        self.chatImageView.image = [UIImage imageNamed:@""];
    }

    [PFCloud callFunctionInBackground:@"getBusinessProfile"
                       withParameters:@{@"business": self.businessId}
                                block:^(NSString * _Nullable result, NSError * _Nullable error)
     {
         if (error) {
             if ([ParseValidation validateError:error]) {
                 [ParseValidation _handleInvalidSessionTokenError:self];
             }
         } else {
             id object = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:0
                                                           error:&error];
             if (error) {
                 DDLogError(@"%@", error);
             } else {
                 if ([object isKindOfClass:[NSDictionary class]]) {
                     NSDictionary *results = object;

                     self.followers = 0;
                     NSString *header = nil;
                     NSString *daySpecial = nil;
                     NSString *website = nil;
                     bool delivery = NO;//
                     NSArray *openOn;
                     NSString *number;
                     bool multiple = NO;
                     bool online = NO;
                     NSString *promo = nil;
                     NSString *promoTextColor = nil;
                     NSString *promoBackground = nil;
                     NSArray *tags;
                     bool verified = NO;
                     long since = 0L;
                     bool favorite = NO;
                     int status = 0;

                     if ([results objectForKey:@"header"] && [results objectForKey:@"header"] != [NSNull null]) {
                         header = [results objectForKey:@"header"];
                     }

                     if ([results objectForKey:@"followers"] && [results objectForKey:@"followers"] != [NSNull null]) {
                         self.followers = [[results objectForKey:@"followers"] unsignedIntegerValue];
                     } else {
                         self.followers = 0;
                     }

                     if ([results objectForKey:@"daySpecial"] && [results objectForKey:@"daySpecial"] != [NSNull null]) {
                         daySpecial = [results objectForKey:@"daySpecial"];
                     }

                     if ([results objectForKey:@"website"] && [results objectForKey:@"website"] != [NSNull null]) {
                         website = [results objectForKey:@"website"];
                     }

                     if ([results objectForKey:@"delivery"] && [results objectForKey:@"delivery"] != [NSNull null]) {
                         delivery = [[results objectForKey:@"delivery"] boolValue];
                     }

                     if ([results objectForKey:@"openOn"] && [results objectForKey:@"openOn"] != [NSNull null]) {
                         openOn = [results objectForKey:@"openOn"];
                     }

                     if ([results objectForKey:@"number"] && [results objectForKey:@"number"] != [NSNull null]) {
                         number = [results objectForKey:@"number"];
                     }

                     if ([results objectForKey:@"multiple"] && [results objectForKey:@"multiple"] != [NSNull null]) {
                         multiple = [[results objectForKey:@"multiple"] boolValue];
                     }

                     if ([results objectForKey:@"online"] && [results objectForKey:@"online"] != [NSNull null]) {
                         online = [[results objectForKey:@"online"] boolValue];
                     }

                     if ([results objectForKey:@"promo"] && [results objectForKey:@"promo"] != [NSNull null]) {
                         promo = [results objectForKey:@"promo"];
                     }

                     if ([results objectForKey:@"promoColor"] && [results objectForKey:@"promoColor"] != [NSNull null]) {
                         promoTextColor = [results objectForKey:@"promoColor"];
                     }

                     if ([results objectForKey:@"promoBack"] && [results objectForKey:@"promoBack"] != [NSNull null]) {
                         promoBackground = [results objectForKey:@"promoBack"];
                     }

                     if ([results objectForKey:@"tags"] && [results objectForKey:@"tags"] != [NSNull null]) {
                         tags = [results objectForKey:@"tags"];
                     }

                     if ([results objectForKey:@"verified"] && [results objectForKey:@"verified"] != [NSNull null]) {
                         verified = [[results objectForKey:@"verified"] boolValue];
                     }

                     if ([results objectForKey:@"since"] && [results objectForKey:@"since"] != [NSNull null]) {
                         since = [[results objectForKey:@"since"] longValue];
                     }

                     if ([results objectForKey:@"favorite"] && [results objectForKey:@"favorite"] != [NSNull null]) {
                         favorite = [[results objectForKey:@"favorite"] boolValue];
                     }

                     if ([results objectForKey:@"status"] && [results objectForKey:@"status"] != [NSNull null]) {
                         status = [[results objectForKey:@"status"] intValue];
                     }

                     if (header != nil) {
                         [self.headerImage sd_setImageWithURL:[NSURL URLWithString:header]
                                             placeholderImage:[UIImage imageNamed:@"im_help_pattern"]];
                     }

                     if (promo != nil || promoBackground != nil) {
                         //mLlSpecialPromoContainer.setVisibility(View.VISIBLE);

                         if (promo != nil) {
                             //mRtvSpecialPromo.setVisibility(View.VISIBLE);
                             //mSdvSpecialPromo.setVisibility(View.VISIBLE);

                             if (promoTextColor != nil) {
                                 @try {
                                     //mRtvSpecialPromo.setTextColor(Color.parseColor(promoTextColor));
                                 } @catch (NSException *exception) {
                                     //mRtvSpecialPromo.setTextColor(Color.WHITE);
                                 }
                             }
                         }

                         if (promoBackground != nil) {
                             //mSdvSpecialPromo.setVisibility(View.VISIBLE);

                             //Uri uri;

                             if([promoBackground length]) {
                                 //uri = Utils.getDefaultImage(this, R.drawable.specialpromo_dropshadow);
                             } else {
                                 //uri = Uri.parse(promoBackground);
                             }

                             //mSdvSpecialPromo.setImageURI(uri);
                         }
                     }

                     // Status
                     switch (status) {
                         case 0: {
                             self.statusView.backgroundColor = [Colors profileOnline];
                             break;
                         }
                         case 1: {
                             self.statusView.backgroundColor = [Colors profileAway];
                             break;
                         }
                         case 2: {
                             self.statusView.backgroundColor = [Colors profileOffline];
                             break;
                         }
                     }

                     if (favorite) {
                         [self changeFavorite:YES];
                     }

                     self.followersLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)self.followers];

                     if (website != nil) {
                         //self.websiteLabel.text = website;
                     } else {
                         //mltvLink.setText(R.string.profile_no_website_message);
                         //self.websiteLabel.text = website;
                     }

                     if (number != nil) {
                         //self.contactNumberLabel.text = number;
                     } else {
                         //mltvContactNumber.setText(R.string.profile_no_number_message);
                         //self.contactNumberLabel.text = number;
                     }

                     if (delivery) {
                         //mIvDelivery.setImageDrawable(ContextCompat.getDrawable(this, R.drawable.ic_check));
                         //mLtvDelivery.setText(getString(R.string.profile_delivery_yes));
                     } else {
                         //mIvDelivery.setImageDrawable(ContextCompat.getDrawable(this, R.drawable.ic_cancel));
                         //mLtvDelivery.setText(getString(R.string.profile_delivery_no));
                     }

                     if (multiple) {
                         // Multiple locations
                         //mRtvLocationDescription.setText(R.string.profile_location_multiple_location);
                     } else if (online) {
                         // Just online
                         //mRtvLocationDescription.setText(R.string.profile_location_online_location);
                         //mBtnLocation.setVisibility(View.GONE);
                     } else {
                         // One location
                         //mRtvLocationDescription.setText(R.string.profile_location_one_location);
                     }

                 }
             }
         }

         self.favoriteButton.enabled = YES;
     }];

    //    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
    //        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    //        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    //        blurEffectView.frame = self.view.bounds;
    //        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //        [self.view insertSubview:blurEffectView atIndex:0];
    //    } else {

    //    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(self.tapOutsideRecognizer == nil) {
        self.tapOutsideRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(handleTapBehind:)];
        self.tapOutsideRecognizer.numberOfTapsRequired = 1;
        self.tapOutsideRecognizer.cancelsTouchesInView = false;
        self.tapOutsideRecognizer.delegate = self;
        [self.view.window addGestureRecognizer:self.tapOutsideRecognizer];
    }

    UIColor *myBackground = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:0.3];
    UIView* baseView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                0,
                                                                [[UIScreen mainScreen] bounds].size.width,
                                                                [[UIScreen mainScreen] bounds].size.height)];
    baseView.tag = 512;
    baseView.backgroundColor = myBackground;
    [self.view insertSubview:baseView atIndex:0];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if(self.tapOutsideRecognizer != nil) {
        [self.view.window removeGestureRecognizer:self.tapOutsideRecognizer];
        self.tapOutsideRecognizer = nil;
    }
}

#pragma mark - Action Method -

- (void)handleTapBehind:(UITapGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [sender locationInView:self.view];

        if (!CGRectContainsPoint([self.containerView frame], location)) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)changeFavorite:(BOOL)favorite {
    self.select = favorite;
    CGAffineTransform expandTransform = CGAffineTransformMakeScale(1.2, 1.2);
    self.favoriteImageView.transform = expandTransform;

    if (favorite) {
        self.favoriteImageView.image = [UIImage imageNamed:@"ic_fav"];
    } else {
        self.favoriteImageView.image = [UIImage imageNamed:@"ic_fav_not"];
    }

    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:0.4
          initialSpringVelocity:0.2
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.favoriteImageView.transform = CGAffineTransformIdentity;
                     } completion:nil];
}

#pragma mark - UIButton Methods -

- (IBAction)chatPressed:(UIButton *)sender {
    __block YapContact *bs = nil;
    [[DatabaseManager sharedInstance].newConnection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction)
    {
        bs = [transaction objectForKey:self.business.objectId inCollection:[YapContact collection]];
    }];
    // Get reference to the destination view controller
    UIStoryboard *mainStoryboard = self.storyboard;
    ConversationViewController *destinationViewController = (ConversationViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"conversationViewController"];
    
    // Pass any objects to the view controller here, like...
    if (bs) {
        [destinationViewController initWithBuddy:bs];
    } else {
        if (self.business) {
            [destinationViewController initWithBusiness:self.business withAvatarUrl:nil];
        } else {
            Business *business = [Business objectWithoutDataWithObjectId:self.yapbusiness.uniqueId];
            business.displayName = self.yapbusiness.displayName;
            business.conversaID = self.yapbusiness.conversaId;
            [destinationViewController initWithBusiness:business withAvatarUrl:self.yapbusiness.avatarUrl];
        }
    }

    if ([[self presentingViewController] isKindOfClass:[UITabBarController class]]) {
        // From category view controller
        UITabBarController *one = (UITabBarController*)[self presentingViewController];
        UINavigationController *two = (UINavigationController*)one.selectedViewController;
        [self dismissViewControllerAnimated:YES completion:^{
            [two pushViewController:destinationViewController animated:YES];
        }];
    } else if ([[self presentingViewController] isKindOfClass:[UIViewController class]]) {
        // From search view controller
        UIViewController *one = [self presentingViewController];
        UINavigationController *two = one.navigationController;
        [self dismissViewControllerAnimated:YES completion:^{
            [two pushViewController:destinationViewController animated:YES];
        }];
    }
}

- (IBAction)favoritePressed:(UIButton *)sender {
    sender.enabled = NO;

    if ([self isSelected]) {
        [AppJobs addFavoriteJob:self.businessId favorite:NO];
        [self changeFavorite:NO];
        self.followers--;
        self.followersLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)self.followers];
    } else {
        [AppJobs addFavoriteJob:self.businessId favorite:YES];
        [self changeFavorite:YES];
        self.followers++;
        self.followersLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)self.followers];
    }

    sender.enabled  = YES;
}

- (IBAction)sharePressed:(UIButton *)sender {
    NSString *textToShare = NSLocalizedString(@"settings_home_share_text", nil);
    NSString *link;

    if (self.business) {
        link = [@"https://9ozf.test-app.link/" stringByAppendingString:self.business.conversaID];
    } else {
        link = [@"https://9ozf.test-app.link/" stringByAppendingString:self.yapbusiness.conversaId];
    }

    NSArray *objectsToShare = @[textToShare, link];

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];

    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];

    activityVC.excludedActivityTypes = excludeActivities;

    [self presentViewController:activityVC animated:YES completion:nil];
}

- (IBAction)closePressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation Method -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"FromProfileToChat"]) {
        __block YapContact *bs = nil;
        [[DatabaseManager sharedInstance].newConnection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
            bs = [transaction objectForKey:self.business.objectId inCollection:[YapContact collection]];
        }];
        // Get reference to the destination view controller
        UINavigationController *navController = [segue destinationViewController];
        ConversationViewController *destinationViewController = (ConversationViewController*)([navController viewControllers][0]);

        // Pass any objects to the view controller here, like...
        if (bs) {
            [destinationViewController initWithBuddy:bs];
        } else {
            if (self.business) {
                [destinationViewController initWithBusiness:self.business withAvatarUrl:nil];
            } else {
                Business *business = [Business objectWithoutDataWithObjectId:self.yapbusiness.uniqueId];
                business.displayName = self.yapbusiness.displayName;
                business.conversaID = self.yapbusiness.conversaId;

                [destinationViewController initWithBusiness:business withAvatarUrl:self.yapbusiness.avatarUrl];
            }
        }
    }
}

@end
