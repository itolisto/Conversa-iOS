//
//  Constants.h
//  Conversa
//
//  Created by Edgar Gomez on 9/28/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

@import Foundation;

// Options class <------- REVISAR ESTA CLASE SI ES NECESARIA
extern NSString *const kClassOptions;
extern NSString *const kOptionsCodeKey;
extern NSString *const kOptionsDefaultValueKey;

// BusinessOptions class
extern NSString *const kClassBusinessOptions;
extern NSString *const kBusinessOptionsBusinessKey;
extern NSString *const kBusinessOptionsOptionKey;
extern NSString *const kBusinessOptionsValueKey;
extern NSString *const kBusinessOptionsActiveKey;

// BusinessCategory class
extern NSString *const kClassBusinessCategory;
extern NSString *const kBusinessCategoryCategoryKey;
extern NSString *const kBusinessCategoryBusinessKey;
extern NSString *const kBusinessCategoryRelevanceKey;
extern NSString *const kBusinessCategoryPositionKey;
extern NSString *const kBusinessCategoryActiveKey;

// Customer class
extern NSString *const kClassCustomer;
extern NSString *const kCustomerUserInfoKey;

// Business class
extern NSString *const kClassBusiness;
extern NSString *const kBusinessBusinessInfoKey;
extern NSString *const kBusinessDisplayNameKey;
extern NSString *const kBusinessAboutKey;
extern NSString *const kBusinessAvatarKey;
extern NSString *const kBusinessConversaIdKey;
extern NSString *const kBusinessActiveKey;
extern NSString *const kBusinessCountryKey;
extern NSString *const kBusinessVerifiedKey;
extern NSString *const kBusinessBusinessKey;
extern NSString *const kBusinessTagTagKey;

// Category class
extern NSString *const kClassCategory;

// Contact class
extern NSString *const kClassContact;
extern NSString *const kContactFromUserKey;
extern NSString *const kContactToBusinessKey;
extern NSString *const kContactActiveChatKey;

// Favorite class
extern NSString *const kClassFavorite;
extern NSString *const kFavoriteFromUserKey;
extern NSString *const kFavoriteToBusinessKey;
extern NSString *const kFavoriteIsFavoriteKey;

// Message class
extern NSString *const kClassMessage;
extern NSString *const kMessageFromUserKey;
extern NSString *const kMessageToUserKey;
extern NSString *const kMessageFileKey;
extern NSString *const kMessageThumbKey;
extern NSString *const kMessageWidthKey;
extern NSString *const kMessageHeightKey;
extern NSString *const kMessageDurationKey;
extern NSString *const kMessageLocationKey;
extern NSString *const kMessageTextKey;

// Image Quality
typedef NS_ENUM(NSInteger, ConversaImageQuality) {
    ConversaImageQualityHigh    = 1,
    ConversaImageQualityMedium  = 2,
    ConversaImageQualityLow     = 3
};

// PubNubMessage
typedef NS_ENUM(NSInteger, PubNubMessageType){
    kMessageTypeText    = 1,
    kMessageTypeAudio   = 2,
    kMessageTypeVideo   = 3,
    kMessageTypeImage   = 4,
    kMessageTypeLocation  = 5
};
extern NSString *const kPubNubMessageTextKey;
extern NSString *const kPubNubMessageFromKey;
extern NSString *const kPubNubMessageTypeKey;

// Messages media location
extern NSString *const kMessageMediaAvatarLocation;
extern NSString *const kMessageMediaImageLocation;
extern NSString *const kMessageMediaVideoLocation;
extern NSString *const kMessageMediaAudioLocation;

// User class
extern NSString *const kUserAvatarKey;
extern NSString *const kUserUsernameKey;
extern NSString *const kUserEmailKey;
extern NSString *const kUserPasswordKey;
extern NSString *const kUserTypeKey;

// Statistics class
extern NSString *const kClassStatistics;
extern NSString *const kStatisticsBusinessKey;
extern NSString *const kStatisticsCriteria1Key;
extern NSString *const kStatisticsCriteria2Key;
extern NSString *const kStatisticsCriteria3Key;
extern NSString *const kStatisticsCriteria4Key;
extern NSString *const kStatisticsCriteria5Key;
extern NSString *const kStatisticsCriteria6Key;

// General
extern NSString *const kObjectRowObjectIdKey;
extern NSString *const kObjectRowCreatedAtKey;

// Other
extern NSString *const kAccountAvatarName;
extern NSString *const kNSDictionaryBusiness;
extern NSString *const kNSDictionaryChangeValue;
extern NSString *const kSettingKeyLanguage;
extern NSString *const kAppVersionKey;
extern NSString *const kYapDatabaseServiceName;
extern NSString *const kYapDatabasePassphraseAccountName;
extern NSString *const kYapDatabaseName;
extern NSString *const kMuteUserNotificationName;

// YapDatabase
#define		YapDatabaseModifiedNotificationUpdate   @"update"

// Messages status & info
#define		STATUS_LOADING						1
#define		STATUS_FAILED						2
#define		STATUS_SUCCEED						3

// Messages dictionary keys
#define     MESSAGE_TEXT_KEY      @"text"
#define     MESSAGE_LATI_KEY      @"latitude"
#define     MESSAGE_LONG_KEY      @"longitude"
#define     MESSAGE_FILENAME_KEY  @"filename"
#define     MESSAGE_SIZE_KEY      @"size"

#define		LINK_PARSE							@"https://files.parsetfss.com"
#define     BLOCK_NOTIFICATION_NAME             @"BlockNotificationName"
#define     SEARCH_NOTIFICATION_NAME            @"SearchNotificationName"
#define     SEARCH_NOTIFICATION_DIC_KEY         @"SearchBarText"
#define     UPDATE_CELL_NOTIFICATION_NAME       @"UpdateCellNotificationName"
#define     UPDATE_CHATS_NOTIFICATION_NAME      @"UpdateChatsNotificationName"
#define     UPDATE_CELL_DIC_KEY                 @"UpdateCellText"

#define		IMAGE_LIMIT         1 //Items
