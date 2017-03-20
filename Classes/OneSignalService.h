//
//  OneSignalService.h
//  Conversa
//
//  Created by Edgar Gomez on 7/18/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

@import Foundation;
#import <OneSignal/OneSignal.h>

@interface OneSignalService : NSObject

+ (OneSignalService *)sharedInstance;
- (void)launchWithOptions:(NSDictionary *)launchOptions;
- (void)processMessage:(NSDictionary*)additionalData;
- (void)registerForPushNotifications;
- (void)startTags;
- (void)unsubscribeFromAllChannels;

@end
