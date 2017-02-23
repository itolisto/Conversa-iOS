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
}

- (void)configureCellWith:(YapContact *)business {
    self.business = business;

    if (business.avatarThumbFileId) {
        [self.photoImageView sd_setImageWithURL:[NSURL URLWithString:business.avatarThumbFileId]
                               placeholderImage:[UIImage imageNamed:@"ic_business_default"]];
    }

    self.conversaIdLabel.text = [@"@" stringByAppendingString:business.conversaId];
    self.displayNameLabel.text = business.displayName;
}

- (void)configureCellWithYap:(YapSearch *)yapbusiness {
    self.yapbusiness = yapbusiness;

    if ([yapbusiness.avatarUrl length]) {
        [self.photoImageView sd_setImageWithURL:[NSURL URLWithString:yapbusiness.avatarUrl]
                               placeholderImage:[UIImage imageNamed:@"ic_business_default"]];
    } else {
        self.photoImageView.image = [UIImage imageNamed:@"ic_business_default"];
    }

    self.conversaIdLabel.text = [@"@" stringByAppendingString:yapbusiness.conversaId];
    self.displayNameLabel.text = yapbusiness.displayName;
}

@end
