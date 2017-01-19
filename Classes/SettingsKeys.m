//
//  SettingsKeys.m
//  Conversa
//
//  Created by Edgar Gomez on 2/27/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

#import "SettingsKeys.h"

@implementation SettingsKeys

// General
NSString *tutorialAlreadyShown = @"tutorialAlreadyShown";
NSString *notificationsCheck   = @"notificationsCheck";

// Account settings
NSString *customerObjectId  = @"customerObjectId";
NSString *customerDisplayName  = @"customerDisplayName";
NSString *customerGender  = @"customerGender";
NSString *customerBirthday  = @"customerBirthday";
NSString *readReceiptsSwitch  = @"readReceiptsSwitch";

// Notifications settings
NSString *inAppSoundSwitch    = @"inAppSoundSwitch";
NSString *inAppPreviewSwitch  = @"inAppPreviewSwitch";
NSString *soundSwitch         = @"soundSwitch";
NSString *previewSwitch       = @"previewSwitch";

// Message settings
NSString *qualityImageSetting = @"qualityImageSetting";
NSString *sendSoundSwitch     = @"sendSoundSwitch";
NSString *receiveSoundSwitch  = @"receiveSoundSwitch";

#pragma mark - Defaults -
+ (NSUserDefaults *)getDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return defaults;
}

#pragma mark - General settings -

+ (void)setTutorialShownSetting:(BOOL)state {
    NSUserDefaults *defaults = [self getDefaults];
    [defaults setBool:state forKey:tutorialAlreadyShown];
    [defaults synchronize];
}

+ (BOOL)getTutorialShownSetting {
    NSUserDefaults *defaults = [self getDefaults];
    return [defaults boolForKey:tutorialAlreadyShown];
}

+ (void)setNotificationsCheck:(BOOL)state {
    NSUserDefaults *defaults = [self getDefaults];
    [defaults setBool:state forKey:notificationsCheck];
    [defaults synchronize];
}

+ (BOOL)getNotificationsCheck {
    NSUserDefaults *defaults = [self getDefaults];
    return [defaults boolForKey:notificationsCheck];
}

#pragma mark - Account settings -
+ (void)setCustomerId:(NSString*)objectId {
    NSUserDefaults *defaults = [self getDefaults];
    [defaults setObject:objectId forKey:customerObjectId];
    [defaults synchronize];
}

+ (NSString*)getCustomerId {
    NSUserDefaults *defaults = [self getDefaults];
    return [defaults stringForKey:customerObjectId];
}

+ (void)setDisplayName:(NSString*)displayName {
    NSUserDefaults *defaults = [self getDefaults];
    [defaults setObject:displayName forKey:customerDisplayName];
    [defaults synchronize];
}

+ (NSString*)getDisplayName {
    NSUserDefaults *defaults = [self getDefaults];
    return [defaults stringForKey:customerDisplayName];
}

+ (void)setGender:(NSUInteger)gender {
    NSUserDefaults *defaults = [self getDefaults];
    [defaults setInteger:gender forKey:customerGender];
    [defaults synchronize];
}

+ (ConversaGender)getGender {
    NSUserDefaults *defaults = [self getDefaults];
    NSUInteger gender = [defaults integerForKey:customerGender];

    switch (gender) {
        case 0:
            return Female;
        case 1:
            return Male;
        default:
            return Unknown;
    }
}

+ (void)setBirthday:(NSUInteger)birthday {
    NSUserDefaults *defaults = [self getDefaults];
    [defaults setInteger:birthday forKey:customerBirthday];
    [defaults synchronize];
}

+ (NSUInteger)getBirthday {
    NSUserDefaults *defaults = [self getDefaults];
    return [defaults integerForKey:customerGender];
}

+ (void)setAccountReadSetting:(BOOL) state {
    NSUserDefaults *defaults = [self getDefaults];
    [defaults setBool:state forKey:readReceiptsSwitch];
    [defaults synchronize];
}

+ (BOOL)getAccountReadSetting {
    NSUserDefaults *defaults = [self getDefaults];
    return [defaults boolForKey:readReceiptsSwitch];
}

#pragma mark - Notifications settings -
+ (void)setNotificationSound:(BOOL) state inApp:(BOOL) inApp {
    NSUserDefaults *defaults = [self getDefaults];
    
    if(inApp) {
        [defaults setBool:state forKey:inAppSoundSwitch];
    } else {
        [defaults setBool:state forKey:soundSwitch];
    }
    
    [defaults synchronize];
}

+ (void)setNotificationPreview:(BOOL) state inApp:(BOOL)inApp {
    NSUserDefaults *defaults = [self getDefaults];
    
    if(inApp) {
        [defaults setBool:state forKey:inAppPreviewSwitch];
    } else {
        [defaults setBool:state forKey:previewSwitch];
    }
    
    [defaults synchronize];
}

+ (BOOL)getNotificationSoundInApp:(BOOL)inApp {
    NSUserDefaults *defaults = [self getDefaults];
    
    if(inApp) {
        return [defaults boolForKey:inAppSoundSwitch];
    }
    
    return [defaults boolForKey:soundSwitch];
}

+ (BOOL)getNotificationPreviewInApp:(BOOL)inApp {
    NSUserDefaults *defaults = [self getDefaults];
    
    if(inApp) {
        return [defaults boolForKey:inAppPreviewSwitch];
    }
    
    return [defaults boolForKey:previewSwitch];
}


#pragma mark - Message settings -
+ (void)setMessageImageQuality:(ConversaImageQuality)quality {
    NSUserDefaults *defaults = [self getDefaults];
    switch (quality) {
        case ConversaImageQualityHigh:
            [defaults setInteger:1 forKey:qualityImageSetting]; break;
        case ConversaImageQualityMedium:
            [defaults setInteger:2 forKey:qualityImageSetting]; break;
        default:
            [defaults setInteger:3 forKey:qualityImageSetting]; break;
    }
    [defaults synchronize];
}

+ (ConversaImageQuality)getMessageImageQuality {
    NSUserDefaults *defaults = [self getDefaults];
    switch ([defaults integerForKey:qualityImageSetting]) {
        case 1:
            return ConversaImageQualityHigh;
        case 2:
            return ConversaImageQualityMedium;
        default:
            return ConversaImageQualityLow;
    }
}

+ (void)setMessageSoundIncoming:(BOOL)incoming value:(BOOL)state {
    NSUserDefaults *defaults = [self getDefaults];
    
    if(incoming) {
        [defaults setBool:state forKey:receiveSoundSwitch];
    } else {
        [defaults setBool:state forKey:sendSoundSwitch];
    }
    
    [defaults synchronize];
}

+ (BOOL)getMessageSoundIncoming:(BOOL)incoming {
    NSUserDefaults *defaults = [self getDefaults];
    
    if(incoming) {
        return [defaults boolForKey:receiveSoundSwitch];
    } else {
        return [defaults boolForKey:sendSoundSwitch];
    }
}

@end
