//
//  AppDelegate.h
//  Conversa
//
//  Created by Edgar Gomez on 12/10/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

@import UIKit;

@import Ably;
@import UserNotifications;
#import "EDQueue.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, EDQueueDelegate, UNUserNotificationCenterDelegate>
    //ARTPushRegistererDelegate
@property (strong, nonatomic) UIWindow *window;

@end
