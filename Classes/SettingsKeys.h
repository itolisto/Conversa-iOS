//
//  SettingsKeys.h
//  Conversa
//
//  Created by Edgar Gomez on 2/27/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

@import Foundation;
#import "Constants.h"

// General
extern NSString *tutorialAlreadyShown;
extern NSString *firstCategoriesLoad;
extern NSString *codeAlreadyValidated;
// Account settings
extern NSString *readReceiptsSwitch;
extern NSString *customerObjectId;
extern NSString *customerDisplayName;
extern NSString *customerGender;
extern NSString *customerBirthday;
// Notifications settings
extern NSString *inAppSoundSwitch;
extern NSString *inAppPreviewSwitch;
extern NSString *soundSwitch;
extern NSString *previewSwitch;

typedef NS_ENUM(NSUInteger, ConversaGender) {
    Female,
    Male,
    Unknown
};

@interface SettingsKeys : NSObject

// General
+ (void)setTutorialShownSetting:(BOOL)state;
+ (BOOL)getTutorialShownSetting;
+ (void)setCodeValidatedSetting:(BOOL)state;
+ (BOOL)getCodeValidatedSetting;

// Account settings
+ (void)setCustomerId:(NSString*)objectId;
+ (NSString*)getCustomerId;
+ (void)setDisplayName:(NSString*)displayName;
+ (NSString*)getDisplayName;
+ (void)setGender:(NSUInteger)gender;
+ (ConversaGender)getGender;
+ (void)setBirthday:(NSUInteger)birthday;
+ (NSUInteger)getBirthday;
+ (void)setAccountReadSetting:(BOOL)state;
+ (BOOL)getAccountReadSetting;

// Notifications settings
+ (void)setNotificationSound:(BOOL)state inApp:(BOOL)inApp;
+ (void)setNotificationPreview:(BOOL)state inApp:(BOOL)inApp;
+ (BOOL)getNotificationSoundInApp:(BOOL)inApp;
+ (BOOL)getNotificationPreviewInApp:(BOOL)inApp;

// Messages settings
+ (void)setMessageImageQuality:(ConversaImageQuality)quality;
+ (ConversaImageQuality)getMessageImageQuality;

+ (void)setMessageSoundIncoming:(BOOL)incoming value:(BOOL)state;
+ (BOOL)getMessageSoundIncoming:(BOOL)incoming;

@end
