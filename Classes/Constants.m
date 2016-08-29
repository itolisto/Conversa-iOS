//
//  Constants.m
//  Conversa
//
//  Created by Edgar Gomez on 9/28/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "Constants.h"

// Options class
NSString *const kClassOptions           = @"Options";
NSString *const kOptionsCodeKey         = @"code";
NSString *const kOptionsDefaultValueKey = @"defaultValue";

// BusinessOptions class
NSString *const kClassBusinessOptions       = @"BusinessOptions";
NSString *const kBusinessOptionsBusinessKey = @"business";
NSString *const kBusinessOptionsOptionKey   = @"option";
NSString *const kBusinessOptionsValueKey    = @"value";
NSString *const kBusinessOptionsActiveKey   = @"active";

// BusinessCategory class
NSString *const kClassBusinessCategory        = @"BusinessCategory";
NSString *const kBusinessCategoryCategoryKey  = @"category";
NSString *const kBusinessCategoryBusinessKey  = @"business";
NSString *const kBusinessCategoryRelevanceKey = @"relevance";
NSString *const kBusinessCategoryPositionKey  = @"position";
NSString *const kBusinessCategoryActiveKey    = @"active";

// Customer class
NSString *const kClassCustomer       = @"Customer";
NSString *const kCustomerUserInfoKey = @"userInfo";

// Business class
NSString *const kClassBusiness           = @"Business";
NSString *const kBusinessBusinessInfoKey = @"businessInfo";
NSString *const kBusinessConversaIdKey   = @"conversaID";
NSString *const kBusinessActiveKey       = @"active";
NSString *const kBusinessCountryKey      = @"country";
NSString *const kBusinessVerifiedKey     = @"verified";
NSString *const kBusinessBusinessKey     = @"business";
NSString *const kBusinessTagTagKey       = @"tags";

// Category class
NSString *const kClassCategory = @"Category";

// Contact class
NSString *const kClassContact         = @"UserContact";
NSString *const kContactFromUserKey   = @"fromUser";
NSString *const kContactToBusinessKey = @"toBusiness";
NSString *const kContactActiveChatKey = @"activeChat";

// Favorite class
NSString *const kClassFavorite         = @"UserFavorite";
NSString *const kFavoriteFromUserKey   = @"fromUser";
NSString *const kFavoriteToBusinessKey = @"toBusiness";
NSString *const kFavoriteIsFavoriteKey = @"isCurrentlyFavorite";

// Message class
NSString *const kClassMessage       = @"Message";
NSString *const kMessageFromUserKey = @"fromUser";
NSString *const kMessageToUserKey   = @"toUser";
NSString *const kMessageFileKey     = @"file";
NSString *const kMessageThumbKey    = @"thumbnail";
NSString *const kMessageWidthKey    = @"width";
NSString *const kMessageHeightKey   = @"height";
NSString *const kMessageDurationKey = @"duration";
NSString *const kMessageLocationKey = @"location";
NSString *const kMessageTextKey     = @"text";

// PubNubMessage class
NSString *const kPubNubMessageTextKey = @"message";
NSString *const kPubNubMessageFromKey = @"from";
NSString *const kPubNubMessageTypeKey = @"type";

// Messages media location
NSString *const kMessageMediaImageLocation = @"/image";
NSString *const kMessageMediaVideoLocation = @"/video";
NSString *const kMessageMediaAudioLocation = @"/audio";

// User class
NSString *const kUserAvatarKey   = @"avatar";
NSString *const kUserUsernameKey = @"username";
NSString *const kUserEmailKey    = @"email";
NSString *const kUserPasswordKey = @"password";
NSString *const kUserDisplayNameKey  = @"displayName";
NSString *const kUserTypeKey     = @"userType";

// Statistics class
NSString *const kClassStatistics = @"Statistics";
NSString *const kStatisticsBusinessKey  = @"business";
NSString *const kStatisticsCriteria1Key = @"messagesReceived";
NSString *const kStatisticsCriteria2Key = @"numberOfFollowers";
NSString *const kStatisticsCriteria3Key = @"numberOfProfileViews";
NSString *const kStatisticsCriteria4Key = @"numberOfSearches";
NSString *const kStatisticsCriteria5Key = @"numberOfComplaints";
NSString *const kStatisticsCriteria6Key = @"numberOfMutesByUser";

// General
NSString *const kObjectRowObjectIdKey  = @"objectId";
NSString *const kObjectRowCreatedAtKey = @"createdAt";

// Other
NSString *const kAccountAvatarName          = @"user_avatar.png";
NSString *const kNSDictionaryBusiness       = @"objectBusiness";
NSString *const kNSDictionaryChangeValue    = @"hasChangeValue";
NSString *const kSettingKeyLanguage         = @"userSelectedSetting";
NSString *const kAppVersionKey              = @"kAppVersionKey";
NSString *const kYapDatabaseServiceName     = @"ee.app.conversa";
NSString *const kYapDatabaseName            = @"ConversaYap.sqlite";
NSString *const kYapDatabasePassphraseAccountName = @"YapDatabasePassphraseAccountName";
NSString *const kMuteUserNotificationName   = @"kMuteUserNotificationName";