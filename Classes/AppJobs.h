//
//  AppJobs.h
//  Conversa
//
//  Created by Edgar Gomez on 11/30/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

@import Foundation;

@class YapContact;

@interface AppJobs : NSObject

+ (void)addCustomerDataJob;
+ (void)addDownloadAvatarJob:(YapContact*)buddy;
+ (void)addFavoriteJob:(NSString*)businessId favorite:(BOOL)favorite;
+ (void)addDownloadFileJob:(NSString*)messageId url:(NSString*)url messageType:(NSInteger)messageType;

@end
