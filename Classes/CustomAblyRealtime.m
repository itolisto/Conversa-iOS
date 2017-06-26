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
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"pub-c-42c67520-a6a4-4bb0-a054-809e202a2332"
                                                                     subscribeKey:@"sub-c-48b216f4-4131-11e5-8ea0-0619f8945a4f"];
    configuration.uuid = self.clientId;
    self.ably = [PubNub clientWithConfiguration:configuration];
    //self.ably.filterExpression = [NSString stringWithFormat:@"(senderID!=’%@’)", self.clientId];
    [self.ably addListener:self];
}

- (PubNub*)getAblyRealtime {
    return self.ably;
}

- (NSString *)getPublicConnectionId {
    if (self.ably != nil) {
        return self.ably.uuid;
    }

    return nil;
}

- (void)logout {
    if (self.ably == nil) {
        return;
    }

    [self.ably unsubscribe];
//    [self.ably removeAllPushNotificationsFromDeviceWithPushToken:[SettingsKeys getDisplayName]                                                 andCompletion:^(PNAcknowledgmentStatus *status) {
//
//        if (!status.isError) {
//
//            /**
//             Handle successful push notification disabling for all channels associated with
//             specified device push token.
//             */
//        }
//        else {
//
//            /**
//             Handle modification error. Check 'category' property
//             to find out possible reason because of which request did fail.
//             Review 'errorData' property (which has PNErrorData data type) of status
//             object to get additional information about issue.
//
//             Request can be resent using: [status retry];
//             */
//        }
//    }];
}

- (void)subscribeToChannels {
    [self.ably subscribeToChannels:[self getChannels] withPresence:NO];
}

- (void)subscribeToPushNotifications:(NSData *)devicePushToken {
    [self.ably addPushNotificationsOnChannels:[self getChannels]
                            withDevicePushToken:devicePushToken
                                  andCompletion:^(PNAcknowledgmentStatus *status)
    {
        if (!status.isError) {

            // Handle successful push notification enabling on passed channels.
        }
        else {

            /**
             Handle modification error. Check 'category' property
             to find out possible reason because of which request did fail.
             Review 'errorData' property (which has PNErrorData data type) of status
             object to get additional information about issue.

             Request can be resent using: [status retry];
             */
            [status retry];
        }
    }];
}

- (NSArray<NSString*>*)getChannels {
    NSString * channelname = [SettingsKeys getCustomerId];
    return @[
             [@"upbc_" stringByAppendingString:channelname],
             [@"upvt_" stringByAppendingString:channelname]
             ];
}

#pragma mark - ARTConnection Methods -

// Handle new message from one of channels on which client has been subscribed.
- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {

    // Handle new message stored in message.data.message
    if (![message.data.channel isEqualToString:message.data.subscription]) {
        // Message has been received on channel group stored in message.data.subscription.
    } else {
        // Message has been received on channel stored in message.data.channel.
    }

//    NSLog(@"Received message: %@ on channel %@ at %@", message.data.message,
//          message.data.channel, message.data.timetoken);

    NSError *error;
    NSDictionary *results = (NSDictionary *)message.data.message;

    NSDictionary *messages = [NSJSONSerialization JSONObjectWithData:[[results objectForKey:@"message"] dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:0
                                                               error:&error];
    if (error) {

    } else {
        [self onMessage:messages];
    }
}

// New presence event handling.
- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {

    if (![event.data.channel isEqualToString:event.data.subscription]) {
        // Presence event has been received on channel group stored in event.data.subscription.
    } else {
        // Presence event has been received on channel stored in event.data.channel.
    }

    if (![event.data.presenceEvent isEqualToString:@"state-change"]) {
        NSLog(@"%@ \"%@'ed\"\nat: %@ on %@ (Occupancy: %@)", event.data.presence.uuid,
              event.data.presenceEvent, event.data.presence.timetoken, event.data.channel,
              event.data.presence.occupancy);
    } else {
        NSLog(@"%@ changed state at: %@ on %@ to: %@", event.data.presence.uuid,
              event.data.presence.timetoken, event.data.channel, event.data.presence.state);
    }


}

// Handle subscription status change.
- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {

    if (status.operation == PNSubscribeOperation) {
        // Check whether received information about successful subscription or restore.
        if (status.category == PNConnectedCategory || status.category == PNReconnectedCategory) {
            // Status object for those categories can be casted to `PNSubscribeStatus` for use below.
            PNSubscribeStatus *subscribeStatus = (PNSubscribeStatus *)status;
            if (subscribeStatus.category == PNConnectedCategory) {
                // This is expected for a subscribe, this means there is no error or issue whatsoever.
            } else {

                /**
                 This usually occurs if subscribe temporarily fails but reconnects. This means there was
                 an error but there is no longer any issue.
                 */
            }
        } else if (status.category == PNUnexpectedDisconnectCategory) {

            /**
             This is usually an issue with the internet connection, this is an error, handle
             appropriately retry will be called automatically.
             */
        }
        // Looks like some kind of issues happened while client tried to subscribe or disconnected from
        // network.
        else {

            PNErrorStatus *errorStatus = (PNErrorStatus *)status;
            if (errorStatus.category == PNAccessDeniedCategory) {

                /**
                 This means that PAM does allow this client to subscribe to this channel and channel group
                 configuration. This is another explicit error.
                 */
            }
            else {

                /**
                 More errors can be directly specified by creating explicit cases for other error categories
                 of `PNStatusCategory` such as: `PNDecryptionErrorCategory`,
                 `PNMalformedFilterExpressionCategory`, `PNMalformedResponseCategory`, `PNTimeoutCategory`
                 or `PNNetworkIssuesCategory`
                 */
            }
        }
    }
}

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
                    PFQuery *query = [Business query];
                    [query whereKey:kBusinessActiveKey equalTo:@(YES)];
                    [query selectKeys:@[kBusinessDisplayNameKey, kBusinessConversaIdKey, kBusinessAvatarKey]];

                    [query getObjectInBackgroundWithId:contactId block:^(PFObject * _Nullable object, NSError * _Nullable error)
                     {
                         if (error) {
                             if ([ParseValidation validateError:error]) {
                                 [ParseValidation _handleInvalidSessionTokenError:[self topViewController]];
                             }
                         } else {
                             Business *business = (Business*)object;

                             YapContact *newBuddy = [[YapContact alloc] initWithUniqueId:contactId];
                             newBuddy.accountUniqueId = [Account currentUser].objectId;
                             newBuddy.displayName = business.displayName;
                             newBuddy.conversaId = business.conversaID;

                             @try {
                                 if (business.avatar) {
                                     newBuddy.avatarThumbFileId = [business.avatar url];
                                 } else {
                                     newBuddy.avatarThumbFileId = @"";
                                 }
                             } @catch (NSException *exception) {
                                 newBuddy.avatarThumbFileId = @"";
                             } @catch (id exception) {
                                 newBuddy.avatarThumbFileId = @"";
                             }

                             newBuddy.composingMessageString = @"";
                             newBuddy.blocked = NO;
                             newBuddy.mute = NO;
                             newBuddy.lastMessageDate = [NSDate date];

                             [connection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
                                 [newBuddy saveWithTransaction:transaction];
                             } completionBlock:^{
                                 [AppJobs addDownloadAvatarJob:newBuddy];

                                 [self messageId:messageId contactId:contactId messageType:messageType results:results connection:connection withContact:newBuddy];
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

    // Save to Local Database
    message = [[YapMessage alloc] initWithId:messageId];
    message.delivered = statusReceived;
    message.buddyUniqueId = contactId;
    message.messageType = messageType;

    if ([results objectForKey:@"agent"]) {
        message.fromConversa = YES;
    }

    if ([[SettingsKeys getCustomerId] isEqualToString:contactId]) {
        message.incoming = NO;
    } else {
        message.incoming = YES;
    }

    switch (messageType) {
        case kMessageTypeText: {
            message.text = [results objectForKey:@"message"];
            break;
        }
        case kMessageTypeLocation: {
            CLLocation *location = [[CLLocation alloc]
                                    initWithLatitude:[[results objectForKey:@"latitude"] doubleValue]
                                    longitude:[[results objectForKey:@"longitude"] doubleValue]];
            message.location = location;
            break;
        }
        case kMessageTypeVideo:
        case kMessageTypeAudio: {
            message.delivered = statusDownloading;
            message.bytes = [[results objectForKey:@"size"] floatValue];
            message.duration = [NSNumber numberWithInteger:[[results objectForKey:@"duration"] integerValue]];
            message.remoteUrl = [results objectForKey:@"file"];
            [AppJobs addDownloadFileJob:message.uniqueId url:message.remoteUrl messageType:messageType];
            break;
        }
        case kMessageTypeImage: {
            message.delivered = statusDownloading;
            message.bytes = [[results objectForKey:@"size"] floatValue];
            message.width = [[results objectForKey:@"width"] floatValue];
            message.height = [[results objectForKey:@"height"] floatValue];
            message.remoteUrl = [results objectForKey:@"file"];
            [AppJobs addDownloadFileJob:message.uniqueId url:message.remoteUrl messageType:messageType];
            break;
        }
    }

    //    if (self.delegate && [self.delegate respondsToSelector:@selector(messageReceived:from:)]) {
    //        if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    //        {
    //            [self.delegate messageReceived:message from:contact];
    //            return;
    //        }
    //    }

    [connection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction)
     {
         [message saveWithTransaction:transaction];
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
