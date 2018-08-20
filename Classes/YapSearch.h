//
//  YapSearch.h
//  Conversa
//
//  Created by Edgar Gomez on 2/15/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

@import UIKit;

#import "YapDatabaseObject.h"
#import <YapDatabase/YapDatabaseRelationshipNode.h>

extern const struct YapSearchEdges {
    __unsafe_unretained NSString *account;
} YapSearchEdges;

@interface YapSearch : YapDatabaseObject <YapDatabaseRelationshipNode>

@property (nonatomic, strong) NSString *accountUniqueId; // Used to point to this account

@property (nonatomic, strong) NSString *conversaId;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic, strong) NSDate *searchDate;

- (void)saveNew:(YapDatabaseConnection*)connection;

+ (void)clearAllRecentSearches;
+ (NSArray*) recentSearchesWithTransaction:(YapDatabaseReadTransaction *)transaction;
+ (NSUInteger)numberOfRecentSearchesWithTransaction:(YapDatabaseReadTransaction *)transaction;

@end
