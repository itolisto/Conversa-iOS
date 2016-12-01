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
#import "NSFileManager+Conversa.h"
#import "ConversationViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

//#import "Conversa-Swift.h"

@interface ProfileDialogViewController ()

@property (assign, nonatomic) NSUInteger followers;
@property (strong, nonatomic) NSString* businessId;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *conversaIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;

@property (weak, nonatomic) IBOutlet UIImageView *headerImage;

@end

@implementation ProfileDialogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.avatarImage.backgroundColor = [UIColor clearColor];
    self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.width / 2;
}

- (void)viewWillAppear:(BOOL)animated {
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

    //    self.favoriteButton.enabled = NO;
    //    self.favoriteButton.imageColorOn = [Colors redColor];
    //    self.favoriteButton.circleColor = [Colors redColor];
    //    self.favoriteButton.lineColor = [UIColor orangeColor];
    //
    //    if (!_enable) {
    //        self.chatButton.enabled = NO;
    //        self.chatButton.imageColorOff = [UIColor lightGrayColor];
    //    }

    [PFCloud callFunctionInBackground:@"profileInfo"
                       withParameters:@{@"business": self.businessId}
                                block:^(NSString * _Nullable result, NSError * _Nullable error)
     {
         if (error) {
             [ParseValidation validateError:error controller:self];
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

                     //self.favoriteButton.enabled = YES;

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
                         case 1: {
                             //shapeDrawable = (GradientDrawable) getDrawable(R.drawable.circular_status_online);
                             break;
                         }
                         case 2: {
                             //shapeDrawable = (GradientDrawable) getDrawable(R.drawable.circular_status_offline);
                             break;
                         }
                         default: {
                             //shapeDrawable = (GradientDrawable) getDrawable(R.drawable.circular_status_away);
                             break;
                         }
                     }

                     //mIvStatus.setVisibility(View.VISIBLE);
                     //mIvStatus.setBackground(shapeDrawable);

                     if (favorite) {
                         //[self.favoriteButton beginWithSelectedState];
                     }

                     self.followersLabel.text = [NSString stringWithFormat:@"%ld", self.followers];

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
     }];
}

#pragma mark - UIButton Methods -

- (IBAction)shareButtonPressed:(UIButton *)sender {

}

- (IBAction)favoritePressed:(UIButton *)sender {
    sender.enabled = NO;

    if ([sender isSelected]) {
        [AppJobs addFavoriteJob:self.businessId favorite:NO];
        //[sender deselect];
        self.followers--;
    } else {
        [AppJobs addFavoriteJob:self.businessId favorite:YES];
        //[sender select];
        self.followers++;
    }

    sender.enabled  = YES;
}

- (IBAction)closePressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TTTAttributedLabelDelegate Methods -

//- (void)attributedLabel:(TTTAttributedLabel *)label
//   didSelectLinkWithURL:(NSURL *)url {
//    if (![[UIApplication sharedApplication] openURL:url]) {
//        NSLog(@"%@%@",@"Failed to open url:",[url description]);
//    }
//}
//
//- (void)attributedLabel:(TTTAttributedLabel *)label
//didSelectLinkWithAddress:(NSDictionary *)addressComponents {
//    if ([[UIApplication sharedApplication]
//         canOpenURL:[NSURL URLWithString:@"waze://"]]) {
//
//        // Waze is installed. Launch Waze and start navigation
//        NSString *urlStr =
//        [NSString stringWithFormat:@"waze://?q=%@",
//         [addressComponents objectForKey:@"address"]];
//
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
//
//    } else {
//        // Waze is not installed. Launch AppStore to install Waze app
//        [[UIApplication sharedApplication] openURL:[NSURL
//                                                    URLWithString:@"http://itunes.apple.com/us/app/id323229106"]];
//    }
//}
//
//- (void)attributedLabel:(TTTAttributedLabel *)label
//didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
//    phoneNumber = [@"telprompt://" stringByAppendingString:phoneNumber];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
//}

#pragma mark - Navigation Method -

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

+ (void)controller:(UIViewController*)fromController
          business:(Business*)business
       yapbusiness:(YapSearch*)yapbusiness
            enable:(BOOL)enable
            device:(NSString*)machine
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *navigationController;
    MZFormSheetPresentationViewController *formSheetController;
    CGSize size;

    // or pass in UILayoutFittingCompressedSize to size automatically with auto-layout
    if ([machine isEqualToString:@"iPhone7,1"] || [machine isEqualToString:@"iPhone8,2"] || [machine isEqualToString:@"iPhone9,2"] || [machine isEqualToString:@"iPhone9,4"])
    {
        // ALL PLUS MODELS (5.5in)
        navigationController = [storyboard instantiateViewControllerWithIdentifier:@"formSheetController"];
        formSheetController = [[MZFormSheetPresentationViewController alloc] initWithContentViewController:navigationController];
        //size = CGSizeMake(289, 454);
        size = CGSizeMake(282, 380);
    }
    else if ([machine isEqualToString:@"iPhone7,2"] || [machine isEqualToString:@"iPhone8,1"] || [machine isEqualToString:@"iPhone9,1"] || [machine isEqualToString:@"iPhone9,3"])
    {
        // ALL NORMAL MODELS (4.7in)
        navigationController = [storyboard instantiateViewControllerWithIdentifier:@"formSheetController"];
        formSheetController = [[MZFormSheetPresentationViewController alloc] initWithContentViewController:navigationController];
        //size = CGSizeMake(262, 412);
        size = CGSizeMake(282, 380);
    }
    else if ([machine isEqualToString:@"i386"] || [machine isEqualToString:@"x86_64"])
    {
        // SIMULATOR
        navigationController = [storyboard instantiateViewControllerWithIdentifier:@"formSheetController"];
        formSheetController = [[MZFormSheetPresentationViewController alloc] initWithContentViewController:navigationController];
        size = CGSizeMake(282, 380);
    }
    else
    {
        // ALL REGULAR MODELS (4in)
        navigationController = [storyboard instantiateViewControllerWithIdentifier:@"formSheetController"];
        formSheetController = [[MZFormSheetPresentationViewController alloc] initWithContentViewController:navigationController];
        //size = CGSizeMake(224, 350);
        size = CGSizeMake(282, 380);
    }

    ProfileDialogViewController *vc = (ProfileDialogViewController*)navigationController;

    if (business) {
        vc.business = business;
    } else {
        vc.yapbusiness = yapbusiness;
    }

    vc.enable = enable;

    formSheetController.presentationController.contentViewSize = size;
    formSheetController.interactivePanGestureDismissalDirection = MZFormSheetPanGestureDismissDirectionNone;
    formSheetController.presentationController.shouldDismissOnBackgroundViewTap = YES;
    formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyleSlideAndBounceFromTop;

    [fromController presentViewController:formSheetController animated:YES completion:nil];
}

@end
