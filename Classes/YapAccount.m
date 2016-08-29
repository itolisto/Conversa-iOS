//
//  YapAccount.m
//  Conversa
//
//  Created by Edgar Gomez on 12/23/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "YapAccount.h"

@implementation YapAccount

+ (void)deleteAccountWithTransaction:(YapDatabaseReadWriteTransaction*)transaction {
    // Automatically deletes all data in Database. This is done by taking
    // advantage from Relationships
    [transaction removeAllObjectsInCollection:[YapAccount collection]];
}

@end
