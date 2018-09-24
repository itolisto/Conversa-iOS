//
//  Business.h
//  Conversa
//
//  Created by Edgar Gomez on 12/15/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

@import Foundation;

@class Business;

typedef void (^BusinessQueryResult)(Business *_Nullable object, NSError *_Nullable error);

@interface Business : NSObject

+ (void)queryForBusiness:(NSString* _Nonnull)businessId block:(BusinessQueryResult _Nonnull)block;

@property (nonatomic, strong) NSString * _Nonnull objectId;
@property (nonatomic, strong) NSString * _Nonnull conversaID;
@property (nonatomic, strong) NSString * _Nonnull displayName;
@property (nonatomic, strong) NSString * _Nullable avatar;

@end
