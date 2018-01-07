//
//  CustomChatCellTableViewCell.m
//  Conversa
//
//  Created by Edgar Gomez on 11/16/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "CustomChatCell.h"

#import "Colors.h"
#import "Business.h"
#import "Constants.h"
#import "YapMessage.h"
#import "YapContact.h"
#import "DatabaseManager.h"
#import "NSFileManager+Conversa.h"
#import <Parse/Parse.h>

@interface CustomChatCell ()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *conversationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *unreadMessage;

@end

@implementation CustomChatCell

- (void)awakeFromNib {
    // Circular
    [super awakeFromNib];
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2;
    self.unreadMessage.layer.cornerRadius   = self.unreadMessage.frame.size.width / 2;
    self.avatarImageView.layer.masksToBounds = YES;
    self.unreadMessage.layer.masksToBounds = YES;
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.borderWidth = 1;
    self.avatarImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)configureCellWith:(YapContact *)business {
    self.business = business;

    UIImage *image = [[NSFileManager defaultManager] loadAvatarFromLibrary:[business.uniqueId stringByAppendingString:@"_avatar.jpg"]];

    if (!image) {
        image = [UIImage imageNamed:@"ic_business_default"];
    }

    self.avatarImageView.image = image;
    self.nameLabel.text = business.displayName;
    [self updateLastMessage:NO];
}

- (void)updateLastMessage:(BOOL)skipConversationText {
    // Regresar a ultimo mensaje
    __block YapMessage *lastMessage = nil;
    
    [[DatabaseManager sharedInstance].newConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        lastMessage = [self.business lastMessageWithTransaction:transaction];
    }];
    
    if (lastMessage) {
        [self setDateString:lastMessage.date];
        
        if (skipConversationText) {
            return;
        }

        self.conversationLabel.text = [self getDisplayText:lastMessage];
        self.unreadMessage.backgroundColor = [UIColor clearColor];
        
        if (!lastMessage.isView) {
            //self.nameLabel.textColor = [UIColor blackColor];
            if (lastMessage.isIncoming) {
                self.unreadMessage.backgroundColor = [Colors blue];
            }
        }
    } else {
        self.nameLabel.textColor = [UIColor blackColor];
        self.dateLabel.text = @"";
        
        self.conversationLabel.text = NSLocalizedString(@"chats_cell_conversation_empty", nil);
        self.unreadMessage.backgroundColor = [UIColor clearColor];
    }
}

- (void)setDateString:(NSDate *)date {
    self.dateLabel.text = [self dateString:date];
}

- (NSString *)dateString:(NSDate *)messageDate {
    NSTimeInterval timeInterval = fabs([messageDate timeIntervalSinceNow]);
    NSString * dateString = nil;

    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *startOfToday, *startOfOtherDay;
    [cal rangeOfUnit:NSCalendarUnitDay startDate:&startOfToday interval:NULL forDate:[NSDate date]];
    [cal rangeOfUnit:NSCalendarUnitDay startDate:&startOfOtherDay interval:NULL forDate:messageDate];
    NSDateComponents *components = [cal components:NSCalendarUnitDay fromDate:startOfOtherDay toDate:startOfToday options:0];
    NSInteger days = [components day];

    if (days == 1) {
        dateString = NSLocalizedString(@"chats_cell_date_yesterday", nil);
    } else if (timeInterval < 60*60*24){
        // show time in format 11:00 PM
        dateString = [NSDateFormatter localizedStringFromDate:messageDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    } else if (timeInterval < 60*60*24*7) {
        // show time in format Monday, Tuesday, Wednesday,...
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"EEEE" options:0 locale:[NSLocale currentLocale]];
        dateString = [dateFormatter stringFromDate:messageDate];
    } else if (timeInterval < 60*60*25*365) {
        // show time in format 11/05
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"dMMM" options:0
                                                                    locale:[NSLocale currentLocale]];
        dateString = [dateFormatter stringFromDate:messageDate];
    } else {
        // show time in format 11/05/2014
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"dMMMYYYY" options:0
                                                                    locale:[NSLocale currentLocale]];
        dateString = [dateFormatter stringFromDate:messageDate];
    }

    return dateString;
}

- (NSString *)getDisplayText:(YapMessage *)message {
    switch (message.messageType) {
        case kMessageTypeText: {
            return [message.text stringByReplacingOccurrencesOfString:@"[\r\n]"
                                                           withString:@""
                                                              options:NSRegularExpressionSearch
                                                                range:NSMakeRange(0, message.text.length)];
        }
        case kMessageTypeLocation: {
            return NSLocalizedString(@"chats_cell_conversation_location", nil);
        }
        case kMessageTypeImage: {
            return NSLocalizedString(@"chats_cell_conversation_image", nil);
        }
        case kMessageTypeVideo: {
            return NSLocalizedString(@"chats_cell_conversation_video", nil);
        }
        case kMessageTypeAudio: {
            return NSLocalizedString(@"chats_cell_conversation_audio", nil);
        }
    }

    return NSLocalizedString(@"chats_cell_conversation_message", nil);
}

@end
