//
//  BaseTableViewController.m
//  ConversaManager
//
//  Created by Edgar Gomez on 12/19/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

#import "BaseTableViewController.h"

#import "Reachability.h"
#import "NSFileManager+Conversa.h"
#import <AudioToolbox/AudioToolbox.h>

@interface BaseTableViewController ()

@end

@implementation BaseTableViewController

#pragma mark - Lifecycle Methods -

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [CustomAblyRealtime sharedInstance].delegate = self;

    if (self.navigationController != nil) {
        Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
        if (networkStatus == NotReachable) {
            [WhisperBridge showPermanentShout:NSLocalizedString(@"no_internet_connection_message", nil)
                                   titleColor:[UIColor whiteColor]
                              backgroundColor:[UIColor redColor]
                       toNavigationController:self.navigationController];
        } else {
            [WhisperBridge hidePermanentShout:self.navigationController];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - ConversationListener Methods -

- (void)messageReceived:(YapMessage *)message from:(YapContact *)from text:(NSString *)text {
    __block NSString *textString = text;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (![SettingsKeys getNotificationPreviewInApp:YES]) {
            textString = nil;
        }

        UIImage *image = [[NSFileManager defaultManager] loadAvatarFromLibrary:[from.uniqueId stringByAppendingString:@"_avatar.jpg"]];

        if (!image) {
            image = [UIImage imageNamed:@"ic_business_default"];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if ([SettingsKeys getNotificationSoundInApp:YES]) {
                NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"sound_notification" ofType:@"mp3"];
                CFURLRef cfString = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:soundPath]);
                SystemSoundID soundID;
                AudioServicesCreateSystemSoundID(cfString, &soundID);
                AudioServicesPlaySystemSound (soundID);
                CFRelease(cfString);
            }

            [WhisperBridge shout:from.displayName
                        subtitle:textString
                 backgroundColor:[UIColor clearColor]
          toNavigationController:self.navigationController
                           image:image
                    silenceAfter:1.8
                          action:nil];
        });
    });
}

#pragma mark - Controller Methods -

- (UIViewController *)topViewController {
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

@end
