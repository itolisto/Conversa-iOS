//
//  AppJobs.m
//  Conversa
//
//  Created by Edgar Gomez on 11/30/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

#import "AppJobs.h"

#import "YapContact.h"

@implementation AppJobs

//+ (void)addCustomerDataJob
//{
//    [[EDQueue sharedInstance] enqueueWithData:nil forTask:@"customerDataJob"];
//}
//
//+ (void)addFavoriteJob:(NSString*)businessId favorite:(BOOL)favorite
//{
//    if (favorite) {
//        [[EDQueue sharedInstance] enqueueWithData:@{@"business" : businessId,
//                                                    @"favorite" : @YES}
//                                          forTask:@"favoriteJob"];
//    } else {
//        [[EDQueue sharedInstance] enqueueWithData:@{@"business" : businessId}
//                                          forTask:@"favoriteJob"];
//    }
//}
//
//+ (void)addDownloadAvatarJob:(YapContact*)buddy
//{
//    if ([buddy.avatarThumbFileId length] == 0) {
//        return;
//    }
//
//    [[EDQueue sharedInstance] enqueueWithData:@{ @"businessId" : buddy.uniqueId,
//                                                 @"url" : buddy.avatarThumbFileId}
//                                      forTask:@"downloadAvatarJob"];
//}
//
//+ (void)addDownloadFileJob:(NSString*)messageId url:(NSString*)url messageType:(NSInteger)messageType
//{
//    if ([url length] == 0) {
//        return;
//    }
//
//    [[EDQueue sharedInstance] enqueueWithData:@{@"messageId" : messageId,
//                                                @"url" : url,
//                                                @"type" : @(messageType)}
//                                      forTask:@"downloadFileJob"];
//}
//
//+ (void)addRemoveConversationJob:(NSString*)customerId url:(NSString*)businessId {
//    [[EDQueue sharedInstance] enqueueWithData:@{@"customerId" : customerId,
//                                                @"businessId" : businessId}
//                                      forTask:@"removeConversationJob"];
//}

@end
