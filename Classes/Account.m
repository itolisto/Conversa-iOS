//
//  Account.m
//  Conversa
//
//  Created by Edgar Gomez on 12/15/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "Account.h"

#import "bCategory.h"
#import "YapAccount.h"
#import "DatabaseManager.h"
#import "CustomAblyRealtime.h"
#import <Parse/PFObject+Subclass.h>

@implementation Account

@dynamic email;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return [super parseClassName];
}

+ (void)logOut {
    [[CustomAblyRealtime sharedInstance] logout];
    [[DatabaseManager sharedInstance].newConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction)
    {
        [YapAccount deleteAccountWithTransaction:transaction];
    }];
    [bCategory unpinAllObjectsInBackground];
    [super logOut];
}

- (NSString *)getPrivateChannel {
    return [NSString stringWithFormat:@"%@_pvt", [self objectId]];
}

- (NSString *)getPublicChannel {
    return [NSString stringWithFormat:@"%@_pbc", [self objectId]];
}

@end
