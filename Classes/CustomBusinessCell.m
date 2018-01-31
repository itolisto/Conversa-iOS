//
//  CustomBusinessCell.m
//  Conversa
//
//  Created by Edgar Gomez on 12/2/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

#import "CustomBusinessCell.h"

#import "YapContact.h"
#import "Constants.h"
#import "YapSearch.h"
#import "NSFileManager+Conversa.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation CustomBusinessCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _photoImageView.layer.cornerRadius = _photoImageView.frame.size.width / 2;
    _photoImageView.layer.masksToBounds = YES;
    _photoImageView.layer.borderWidth = 0.7;
    _photoImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)configureCellWith:(YapContact *)business {
    self.business = business;
    
    self.displayNameLabel.text = business.displayName;
    self.conversaIdLabel.text = [@"@" stringByAppendingString:business.conversaId];

    if (business.avatarThumbFileId) {
        [self.photoImageView sd_setImageWithURL:[NSURL URLWithString:business.avatarThumbFileId]
                               placeholderImage:[UIImage imageNamed:@"ic_business_default"]];
    }
}

- (void)configureCellWithYap:(YapSearch *)yapbusiness {
    self.yapbusiness = yapbusiness;

    self.displayNameLabel.text = yapbusiness.displayName;
    self.conversaIdLabel.text = [@"@" stringByAppendingString:yapbusiness.conversaId];

    if ([yapbusiness.avatarUrl length]) {
        [self.photoImageView sd_setImageWithURL:[NSURL URLWithString:yapbusiness.avatarUrl]
                               placeholderImage:[UIImage imageNamed:@"ic_business_default"]];
    } else {
        self.photoImageView.image = [UIImage imageNamed:@"ic_business_default"];
    }
}

@end
