//
//  ProfileViewController.m
//  Conversa
//
//  Created by Edgar Gomez on 3/5/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

#import "ProfileViewController.h"

#import "Log.h"
#import "Colors.h"
#import "EDQueue.h"
#import "Account.h"
#import "Business.h"
#import "Constants.h"
#import "YapContact.h"
#import "DatabaseManager.h"
#import "ParseValidation.h"
#import "NSFileManager+Conversa.h"
#import "ConversationViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "Conversa-Swift.h"

@interface ProfileViewController ()

@property (assign, nonatomic) NSUInteger followers;

@property (weak, nonatomic) IBOutlet DOFavoriteButton *favoriteButton;
@property (weak, nonatomic) IBOutlet DOFavoriteButton *chatButton;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *conversaIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;

@property (weak, nonatomic) IBOutlet UILabel *openLabel;

@property (weak, nonatomic) IBOutlet UILabel *conversaTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryLabel;
@property (weak, nonatomic) IBOutlet UILabel *websiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *deliveryImage;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UINavigationItem *falsd = self.navigationItem;

    UIImageView *share = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_share"]];
    share.frame = CGRectMake(0,0,24,24);

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(shareButtonPressed:)];
    singleTap.numberOfTapsRequired = 1;
    [share setUserInteractionEnabled:YES];
    [share addGestureRecognizer:singleTap];

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:share];
    falsd.rightBarButtonItem = rightButton;

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backButtonPressed:)];
    falsd.leftBarButtonItem = backButton;

    self.navigationController.navigationBar.barTintColor = [Colors greenColor];

    self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.width / 2;

    @try {
        if ([self.business avatar]) {
            [self.avatarImage sd_setImageWithURL:[NSURL URLWithString:[[self.business avatar] url]]
                                placeholderImage:[UIImage imageNamed:@"business_default_light"]];
        } else {
            self.avatarImage.image = [UIImage imageNamed:@"business_default_light"];
        }
    } @catch (NSException *exception) {
        self.avatarImage.image = [UIImage imageNamed:@"business_default_light"];
    }

    self.favoriteButton.enabled = NO;
    self.favoriteButton.imageColorOn = [Colors redColor];
    self.favoriteButton.circleColor = [Colors redColor];
    self.favoriteButton.lineColor = [UIColor orangeColor];

    if (!_enable) {
        self.chatButton.enabled = NO;
        self.chatButton.imageColorOff = [UIColor lightGrayColor];
    }

    self.displayNameLabel.text = self.business.displayName;
    self.conversaIdLabel.text = [@"@" stringByAppendingString:self.business.conversaID];


    [PFCloud callFunctionInBackground:@"profileInfo"
                       withParameters:@{@"business": self.business.objectId}
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

                     if ([results objectForKey:@"followers"]) {
                         self.followers = [[results objectForKey:@"followers"] unsignedIntegerValue];
                     } else {
                         self.followers = 0;
                     }

                     if ([results objectForKey:@"daySpecial"]) {
                         daySpecial = [results objectForKey:@"daySpecial"];
                     }

                     if ([results objectForKey:@"website"]) {
                         website = [results objectForKey:@"website"];
                     }

                     if ([results objectForKey:@"delivery"]) {
                         delivery = [[results objectForKey:@"delivery"] boolValue];
                     }

                     if ([results objectForKey:@"openOn"]) {
                         openOn = [results objectForKey:@"openOn"];
                     }

                     if ([results objectForKey:@"number"]) {
                         number = [results objectForKey:@"number"];
                     }

                     if ([results objectForKey:@"multiple"]) {
                         multiple = [[results objectForKey:@"multiple"] boolValue];
                     }

                     if ([results objectForKey:@"online"]) {
                         online = [[results objectForKey:@"online"] boolValue];
                     }

                     if ([results objectForKey:@"promo"]) {
                         promo = [results objectForKey:@"promo"];
                     }

                     if ([results objectForKey:@"promoColor"]) {
                         promoTextColor = [results objectForKey:@"promoColor"];
                     }

                     if ([results objectForKey:@"promoBack"]) {
                         promoBackground = [results objectForKey:@"promoBack"];
                     }

                     if ([results objectForKey:@"tags"]) {
                         tags = [results objectForKey:@"tags"];
                     }

                     if ([results objectForKey:@"verified"]) {
                         verified = [[results objectForKey:@"verified"] boolValue];
                     }

                     if ([results objectForKey:@"since"]) {
                         since = [[results objectForKey:@"since"] longValue];
                     }

                     if ([results objectForKey:@"favorite"]) {
                         favorite = [[results objectForKey:@"favorite"] boolValue];
                     }

                     if ([results objectForKey:@"status"]) {
                         status = [[results objectForKey:@"status"] intValue];
                     }

                     self.favoriteButton.enabled = YES;

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
                         [self.favoriteButton beginWithSelectedState];
                     }

                     self.followersLabel.text = [NSString stringWithFormat:@"%ld", self.followers];

                     if (website != nil) {
                         self.websiteLabel.text = website;
                     } else {
                         //mltvLink.setText(R.string.profile_no_website_message);
                         self.websiteLabel.text = website;
                     }

                     if (number != nil) {
                         self.contactNumberLabel.text = number;
                     } else {
                         //mltvContactNumber.setText(R.string.profile_no_number_message);
                         self.contactNumberLabel.text = number;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [Colors greenColor];
}

#pragma mark - UIButton Methods -

- (IBAction)shareButtonPressed:(UIButton *)sender {

}

- (IBAction)favoritePressed:(DOFavoriteButton *)sender {
    sender.enabled = NO;

    if ([sender isSelected]) {
        [[EDQueue sharedInstance] enqueueWithData:@{@"business" : self.business.objectId} forTask:@"favorite"];
        [sender deselect];
        self.followers--;
    } else {
        [[EDQueue sharedInstance] enqueueWithData:@{@"business" : self.business.objectId, @"favorite" : @YES} forTask:@"favorite"];
        [sender select];
        self.followers++;
    }

    sender.enabled  = YES;
}

- (IBAction)conversaTimePressed:(UIButton *)sender {

}

- (IBAction)locationsPressed:(UIButton *)sender {

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