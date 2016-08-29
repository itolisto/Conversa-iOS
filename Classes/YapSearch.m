//
//  YapSearch.m
//  Conversa
//
//  Created by Edgar Gomez on 2/15/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

#import "YapSearch.h"

@import YapDatabase;
#import "Constants.h"
#import "DatabaseManager.h"

@implementation YapSearch

- (void)saveNew {
    __block NSUInteger count = 0;
    
    [[DatabaseManager sharedInstance].newConnection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        count = [transaction numberOfKeysInCollection:[YapSearch collection]];
    }];
    
    if (count < 8) {
        [self checkBusinessSave:YES];
    } else {
        [self checkBusinessSave:NO];
    }
}

- (void)checkBusinessSave:(BOOL)save {

    __block YapSearch *firstSearch = nil;
    [[DatabaseManager sharedInstance].newConnection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        firstSearch = [transaction objectForKey:self.uniqueId inCollection:[YapSearch collection]];
    }];
    
    if (firstSearch) {
        // Object already exists. Update
        firstSearch.avatar     = self.avatar;
        firstSearch.searchDate = self.searchDate;
        [[DatabaseManager sharedInstance].newConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction)
        {
            [firstSearch saveWithTransaction:transaction];
        }];
    } else {
        if (save) {
            // Recent searches count is less than 8 so we should save object immediately
            [[DatabaseManager sharedInstance].newConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction)
             {
                 [self saveWithTransaction:transaction];
             }];
        } else {
            // Find oldest search, remove and save new one
            [[DatabaseManager sharedInstance].newConnection asyncReadWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
                [transaction enumerateKeysAndObjectsInCollection:[YapSearch collection]
                                                      usingBlock:^(NSString * _Nonnull key, id  _Nonnull object, BOOL * _Nonnull stop)
                 {
                     if (firstSearch && ([firstSearch.searchDate compare:((YapSearch*)object).searchDate] == NSOrderedDescending)) {
                         if ([firstSearch.uniqueId isEqualToString:self.uniqueId]) {
                             firstSearch.avatar = self.avatar;
                             *stop = YES;
                         } else {
                             firstSearch = (YapSearch *)object;
                         }
                     } else {
                         if (!firstSearch) {
                             firstSearch = (YapSearch *)object;
                         }
                     }
                 }];
            } completionBlock:^{
                // Recent searches count is less than 8 so we should save object immediately
                [[DatabaseManager sharedInstance].newConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction)
                 {
                     // Remove oldest
                     [firstSearch removeWithTransaction:transaction];
                     // Save new one
                     [self saveWithTransaction:transaction];
                 }];
            }];
        }
    }
}

+ (void)clearAllRecentSearches {
    [[DatabaseManager sharedInstance].newConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
        [transaction removeAllObjectsInCollection:[YapSearch collection]];
    }];
}

+ (NSArray*) recentSearchesWithTransaction:(YapDatabaseReadTransaction *)transaction {
    return @[];
}

+ (NSUInteger)numberOfRecentSearchesWithTransaction:(YapDatabaseReadTransaction *)transaction {
    return [transaction numberOfKeysInCollection:[YapSearch collection]];
}

@end
