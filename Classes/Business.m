//
//  Business.m
//  Conversa
//
//  Created by Edgar Gomez on 12/15/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "Business.h"

#import "Constants.h"
#import <Parse/PFObject+Subclass.h>

@implementation Business

@dynamic conversaID;
@dynamic displayName;
@dynamic avatar;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return kClassBusiness;
}

+ (void)queryForBusiness:(NSString*)businessId block:(BusinessQueryResult)block {
    PFQuery *query = [Business query];
    [query whereKey:kBusinessActiveKey equalTo:@(YES)];
    [query selectKeys:@[kBusinessDisplayNameKey, kBusinessConversaIdKey, kBusinessAvatarKey]];
    [query getObjectInBackgroundWithId:businessId block:^(PFObject * _Nullable object, NSError * _Nullable error)
     {
         if (error) {
             block(nil, error);
         } else {
             block((Business*)object, nil);
         }
     }];
}

@end
