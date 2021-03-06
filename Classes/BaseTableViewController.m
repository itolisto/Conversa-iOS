//
//  BaseTableViewController.m
//  ConversaManager
//
//  Created by Edgar Gomez on 12/19/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

#import "BaseTableViewController.h"

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
}

#pragma mark - ConversationListener Methods -

- (void)messageReceived:(YapMessage *)message from:(YapContact *)from {
    if ([SettingsKeys getNotificationPreviewInApp:YES]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSString *text = nil;

            switch (message.messageType) {
                case kMessageTypeText: {
                    text = message.text;
                    break;
                }
                case kMessageTypeLocation: {
                    text = NSLocalizedString(@"chats_cell_conversation_location", nil);
                    break;
                }
                case kMessageTypeVideo: {
                    text = NSLocalizedString(@"chats_cell_conversation_video", nil);
                    break;
                }
                case kMessageTypeAudio: {
                    text = NSLocalizedString(@"chats_cell_conversation_audio", nil);
                    break;
                }
                case kMessageTypeImage: {
                    text = NSLocalizedString(@"chats_cell_conversation_image", nil);
                    break;
                }
                default: {
                    text = NSLocalizedString(@"chats_cell_conversation_message", nil);
                    break;
                }
            }

            UIImage *image = [[NSFileManager defaultManager] loadAvatarFromLibrary:[from.uniqueId stringByAppendingString:@"_avatar.jpg"]];

            if (!image) {
                image = [UIImage imageNamed:@"ic_business_default"];
            }

            dispatch_sync(dispatch_get_main_queue(), ^{
                if ([SettingsKeys getNotificationSoundInApp:YES]) {
                    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"sound_notification" ofType:@"mp3"];
                    CFURLRef cfString = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:soundPath]);
                    SystemSoundID soundID;
                    AudioServicesCreateSystemSoundID(cfString, &soundID);
                    AudioServicesPlaySystemSound (soundID);
                    CFRelease(cfString);
                }

                [[WhisperBridge sharedInstance] shout:from.displayName
                                             subtitle:text
                                      backgroundColor:[UIColor clearColor]
                               toNavigationController:self.navigationController
                                                image:image
                                         silenceAfter:1.8
                                               action:nil];
            });
        });
    }
}

#pragma mark - Controller Methods -

- (UIViewController *)topViewController {
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

@end
