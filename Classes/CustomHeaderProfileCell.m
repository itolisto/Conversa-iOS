//
//  CustomHeaderProfileCell.m
//  Conversa
//
//  Created by Edgar Gomez on 3/4/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

#import "CustomHeaderProfileCell.h"

#import "Colors.h"
#import "Account.h"
#import "Business.h"
#import "Constants.h"
#import "NSFileManager+Conversa.h"

@interface CustomHeaderProfileCell ()

// Header
@property (weak, nonatomic) IBOutlet DOFavoriteButton *chatButton;
@property (weak, nonatomic) IBOutlet DOFavoriteButton *favoriteButton;
@property (weak, nonatomic) IBOutlet PFImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *businessNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *conversaIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *followerNumberLabel;
// Values
@property (strong, nonatomic) NSString *business;
@property (assign, nonatomic) BOOL firstLoad;

@end

@implementation CustomHeaderProfileCell

- (void)awakeFromNib {
    // Initialization code
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2;
    self.firstLoad = YES;
}

- (void)configureHeaderWith:(NSDictionary *)business chatEnable:(BOOL)enable {
    if ([[business objectForKey:@"favorite"] boolValue]) {
        [self.favoriteButton beginWithSelectedState];
    } else {
        [self.favoriteButton deselect];
    }
    
    self.followerNumberLabel.text = [[business objectForKey:@"followers"] stringValue];
    self.favoriteButton.enabled  = YES;
}

- (void)configureHeaderWith:(Business *)business withGoChatEnable:(BOOL)enable {
    self.business = business.objectId;
    self.chatButton.imageColorOff = [Colors greenColor];
    
    self.businessNameLabel.text = business.displayName;
    self.conversaIdLabel.text = [@"@" stringByAppendingString:business.conversaID];
    
    __weak typeof(self) wSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *image = [[NSFileManager defaultManager] loadImageFromCache:[business.businessInfo.objectId stringByAppendingString:@"_avatar.jpg"]];
        
        // When finished call back on the main thread:
        dispatch_async(dispatch_get_main_queue(), ^{
            typeof(self)sSelf = wSelf;
            if (sSelf) {
                self.avatarImageView.image = image;
            }
        });
    });
    
    if(self.firstLoad) {
        self.favoriteButton.enabled = NO;
        self.favoriteButton.imageColorOn = [Colors redColor];
        self.favoriteButton.circleColor = [Colors redColor];
        self.favoriteButton.lineColor = [UIColor orangeColor];
        self.firstLoad = NO;
    }
    
    if (!enable) {
        self.chatButton.enabled = NO;
        self.chatButton.imageColorOff = [UIColor lightGrayColor];
    }
}

- (IBAction)favoritePressed:(DOFavoriteButton *)sender {
    self.favoriteButton.enabled = NO;
    
    if ([sender isSelected]) {
        [PFCloud callFunctionInBackground:@"favorite"
                           withParameters:@{@"business": self.business}
                                    block:^(NSNumber * _Nullable object, NSError * _Nullable error)
         {
             if (!error) {
                 [sender deselect];
             }
             self.favoriteButton.enabled  = YES;
         }];
    } else {
        [PFCloud callFunctionInBackground:@"favorite"
                           withParameters:@{@"business": self.business, @"favorite": @(YES)}
                                    block:^(NSNumber * _Nullable object, NSError * _Nullable error)
         {
             if (!error) {
                 [sender select];
             }
             self.favoriteButton.enabled  = YES;
         }];
    }
}

@end
