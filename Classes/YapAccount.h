//
//  YapAccount.h
//  Conversa
//
//  Created by Edgar Gomez on 12/23/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "YapDatabaseObject.h"

@interface YapAccount : YapDatabaseObject

+ (void)deleteAccountWithTransaction:(YapDatabaseReadWriteTransaction*)transaction;

@end
