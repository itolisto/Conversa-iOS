//
//  OTRBuddy.h
//  Off the Record
//
//  Created by David Chiles on 3/28/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

@import UIKit;
@class YapMessage, YapAccount;
#import "Business.h"
#import "YapDatabaseObject.h"
//#import "YapDatabaseRelationship.h"
#import <YapDatabase/YapDatabaseRelationshipNode.h>

extern const struct YapContactAttributes {
	__unsafe_unretained NSString *displayName;
	__unsafe_unretained NSString *conversaId;
} YapContactAttributes;

extern const struct YapContactEdges {
	__unsafe_unretained NSString *account;
} YapContactEdges;

@interface YapContact : YapDatabaseObject <YapDatabaseRelationshipNode>

@property (nonatomic, strong) NSString *accountUniqueId; // Used to point to this account
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *conversaId;
@property (nonatomic, strong) NSString *statusMessage;
@property (nonatomic, strong) NSString *about;
@property (nonatomic, strong) NSString *composingMessageString;
@property (nonatomic, strong) NSDate *lastMessageDate;
@property (nonatomic, assign) BOOL blocked;
@property (nonatomic, assign) BOOL mute;

+ (NSDictionary*) saveContactWithParseBusiness:(Business *)business
                                 andConnection:(YapDatabaseConnection*)editingConnection
                                       andSave:(BOOL)save;

+ (NSUInteger)numberOfBlockedContacts;

- (void)programActionInHours:(NSInteger)hours
                  isMuting:(BOOL)isMuting;
- (NSInteger)numberOfUnreadMessagesWithTransaction:(YapDatabaseReadTransaction *)transaction;
- (YapMessage *)lastMessageWithTransaction:(YapDatabaseReadTransaction *)transaction;
- (YapAccount*)accountWithTransaction:(YapDatabaseReadTransaction *)transaction;
- (BOOL)setAllMessagesView:(YapDatabaseReadWriteTransaction *)transaction;

- (NSString *)getPublicChannel;
- (NSString *)getPrivateChannel;

@end
