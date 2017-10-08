//
//  CustomAblyRealtime.m
//  Conversa
//
//  Created by Edgar Gomez on 7/18/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

#import "CustomAblyRealtime.h"

#import "Log.h"
#import "AppJobs.h"
#import "Business.h"
#import "YapContact.h"
#import "YapMessage.h"
#import "SettingsKeys.h"
#import "DatabaseManager.h"
#import "ParseValidation.h"
#import <Parse/Parse.h>
#import <CommonCrypto/CommonDigest.h>

@interface CustomAblyRealtime ()

@property(nonatomic, assign)BOOL firstLoad;

@end

@implementation CustomAblyRealtime

+ (CustomAblyRealtime *)sharedInstance {
    __strong static CustomAblyRealtime *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CustomAblyRealtime alloc] init];
    });
    return sharedInstance;
}

// http://stackoverflow.com/a/23608321/5349296
- (NSString*)sha1:(NSString *)input
{
    const char *s=[input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData=[NSData dataWithBytes:s length:strlen(s)];

    uint8_t digest[CC_SHA1_DIGEST_LENGTH]={0};
    CC_SHA1(keyData.bytes, (CC_LONG)keyData.length, digest);
    NSData *out = [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    NSString *hash = [out description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"-" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    return hash;
}

#pragma mark - Connection Methods -

- (instancetype)init
{
    if (self = [super init]) {
        self.firstLoad = NO;
        self.clientId = [self sha1:[[NSUUID UUID] UUIDString]];
    }

    return self;
}

- (void)initAbly {
    SKYContainer *container = [SKYContainer defaultContainer];
    [container configAddress:@"https://your-endpoint.skygeario.com/"]; //Your server endpoint
    [container configureWithAPIKey:@"SKYGEAR_API_KEY"]; //Your Skygear API Key
}

- (SKYContainer*)getAblyRealtime {
    return self.ably;
}

- (NSString *)getPublicConnectionId {
    if (self.ably != nil) {
        return self.clientId;
    }

    return nil;
}

- (void)logout {
    if (self.ably == nil) {
        return;
    }

    [self.ably.pubsub unsubscribe:[@"upvt_" stringByAppendingString:[SettingsKeys getCustomerId]]];
}

- (void)subscribeToChannels {
    [self.ably.pubsub subscribeTo:[@"upvt_" stringByAppendingString:[SettingsKeys getCustomerId]] handler:^(NSDictionary *info)
    {
        NSError *error;
        NSDictionary *results = (NSDictionary *)info;

        NSDictionary *messages = [NSJSONSerialization JSONObjectWithData:[[results objectForKey:@"message"] dataUsingEncoding:NSUTF8StringEncoding]
                                                                 options:0
                                                                   error:&error];
        if (!error) {
            [self onMessage:messages];
        }
    }];
}

- (void)subscribeToPushNotifications:(NSData *)devicePushToken {
    if (devicePushToken == nil) {
        return;
    }


}

- (void)unsubscribeToPushNotification:(NSData *)deviceToken {
//    [self.ably unregisterDeviceCompletionHandler:^(NSString *deviceID, NSError *error) {
//        if (error != nil) {
//            NSLog(@"Cannot unregister device");
//            return;
//        }
//        [container logoutWithCompletionHandler:^(SKYUser *user, NSError *error) {
//            // handle logout result
//        }];
//    }];
}

- (NSArray<NSString*>*)getChannels {
    NSString * channelname = [SettingsKeys getCustomerId];
    return @[
             [@"upbc_" stringByAppendingString:channelname],
             [@"upvt_" stringByAppendingString:channelname]
             ];
}

#pragma mark - ARTConnection Methods -


#pragma mark - Process message Method -

- (void)onMessage:(NSDictionary *)results {
    if ([results valueForKey:@"appAction"]) {
        int action = [[results valueForKey:@"appAction"] intValue];
        switch (action) {
            case 1: {
                NSString *messageId = [results valueForKey:@"messageId"];
                NSString *contactId = [results valueForKey:@"contactId"];
                NSInteger messageType = [[results valueForKey:@"messageType"] integerValue];

                if (messageId == nil || contactId == nil) {
                    return;
                }

                YapDatabaseConnection *connection = [[DatabaseManager sharedInstance] newConnection];
                __block YapContact *buddy = nil;

                [connection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
                    buddy = [YapContact fetchObjectWithUniqueID:contactId transaction:transaction];
                }];

                if (buddy == nil) {
                    [Business queryForBusiness:contactId block:^(Business * _Nullable business, NSError * _Nullable error) {
                        if (error) {
                            if ([ParseValidation validateError:error]) {
                                [ParseValidation _handleInvalidSessionTokenError:[self topViewController]];
                            }
                        } else {
                            [YapContact saveContactWithBusiness:business block:^(YapContact *contact) {
                                [AppJobs addDownloadAvatarJob:contact];
                                [self messageId:messageId contactId:contactId messageType:messageType results:results connection:connection withContact:contact];
                            }];
                        }
                    }];
                } else {
                    [self messageId:messageId contactId:contactId messageType:messageType results:results connection:connection withContact:buddy];
                }
                break;
            }
            case 2: {
                NSString *from = [results valueForKey:@"from"];
                bool isTyping = [[results valueForKey:@"isTyping"] boolValue];
                if (from) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(fromUser:userIsTyping:)]) {
                        [self.delegate fromUser:from userIsTyping:isTyping];
                    }
                }
                break;
            }
        }
    }
}

- (void)messageId:(NSString*)messageId contactId:(NSString*)contactId messageType:(NSInteger)messageType results:(NSDictionary*)results connection:(YapDatabaseConnection*)connection withContact:(YapContact*)contact {
    __block YapMessage *message = nil;

    // Check if message exists
    [connection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        message = [YapMessage fetchObjectWithUniqueID:messageId transaction:transaction];
    }];

    if (message != nil) {
        return;
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:5];

    // Save to Local Database
    [dictionary setObject:messageId forKey:@"messageId"];
    [dictionary setObject:contactId forKey:@"contactId"];
    [dictionary setObject:[NSNumber numberWithInteger:messageType] forKey:@"messageType"];

    if ([results objectForKey:@"agent"]) {
        [dictionary setObject:@YES forKey:@"fromConversa"];
    } else {
        [dictionary setObject:@NO forKey:@"fromConversa"];
    }

    if ([[SettingsKeys getCustomerId] isEqualToString:contactId]) {
        [dictionary setObject:@NO forKey:@"incoming"];
    } else {
        [dictionary setObject:@YES forKey:@"incoming"];
    }

    switch (messageType) {
        case kMessageTypeText: {
            [dictionary setObject:[results objectForKey:@"message"] forKey:@"text"];
            break;
        }
        case kMessageTypeLocation: {
            [dictionary setObject:[results objectForKey:@"latitude"] forKey:@"latitude"];
            [dictionary setObject:[results objectForKey:@"longitude"] forKey:@"longitude"];
            break;
        }
        case kMessageTypeVideo:
        case kMessageTypeAudio: {
            [dictionary setObject:[results objectForKey:@"size"] forKey:@"bytes"];
            [dictionary setObject:[results objectForKey:@"duration"] forKey:@"duration"];
            [dictionary setObject:[results objectForKey:@"file"] forKey:@"file"];
            break;
        }
        case kMessageTypeImage: {
            [dictionary setObject:[results objectForKey:@"size"] forKey:@"bytes"];
            [dictionary setObject:[results objectForKey:@"width"] forKey:@"width"];
            [dictionary setObject:[results objectForKey:@"height"] forKey:@"height"];
            [dictionary setObject:[results objectForKey:@"file"] forKey:@"file"];
            break;
        }
    }

    [YapMessage saveMessageWithDictionary:dictionary block:^(YapMessage *message) {
        [connection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
            contact.lastMessageDate = message.date;
            [contact saveWithTransaction:transaction];
        } completionBlock:^{
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                if(self.delegate && [self.delegate respondsToSelector:@selector(messageReceived:from:)])
                {
                    [self.delegate messageReceived:message from:contact];
                    return;
                }
            } else {
                // We are not active, so use a local notification instead
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                localNotification.alertAction = @"Ver";
                localNotification.soundName = UILocalNotificationDefaultSoundName;
                localNotification.applicationIconBadgeNumber = localNotification.applicationIconBadgeNumber + 1;
                localNotification.alertBody = [NSString stringWithFormat:@"%@: %@",contact.displayName,message.text];
                localNotification.userInfo = @{@"contact":contact.uniqueId};
                [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
            }
        }];
    }];
}

#pragma mark - Class Methods -

- (void)sendTypingStateOnChannel:(NSString*)channelName isTyping:(BOOL)value {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    if (value) {
        [parameters setValue:[SettingsKeys getCustomerId] forKey:@"userId"];
        [parameters setValue:channelName forKey:@"channelName"];
        [parameters setValue:@(1) forKey:@"fromCustomer"];
        [parameters setValue:@(YES) forKey:@"isTyping"];
    } else {
        [parameters setValue:[SettingsKeys getCustomerId] forKey:@"userId"];
        [parameters setValue:channelName forKey:@"channelName"];
        [parameters setValue:@(1) forKey:@"fromCustomer"];
    }

    [PFCloud callFunctionInBackground:@"sendPresenceMessage"
                       withParameters:parameters
                                block:^(id  _Nullable object, NSError * _Nullable error)
     {
         if (error) {
             if ([ParseValidation validateError:error]) {
                 //[ParseValidation _handleInvalidSessionTokenError:nil];
             }
         }
     }];
}

#pragma mark - Help Methods -

- (UIViewController *)topViewController {
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }

    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

@end
