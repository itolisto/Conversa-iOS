//
//  CustomPopularCell.m
//  Conversa
//
//  Created by Edgar Gomez on 01/29/16.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "CustomSearchCell.h"

#import "Business.h"
#import "Constants.h"
#import "YapSearch.h"
#import "NSFileManager+Conversa.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation CustomSearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _photoImageView.layer.cornerRadius = _photoImageView.frame.size.width / 2;
    _photoImageView.layer.masksToBounds = YES;
    _photoImageView.layer.borderWidth = 1;
    _photoImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)configureCellWith:(Business *)business {
    self.business = business;

    @try {
        if (business.avatar) {
            [self.photoImageView sd_setImageWithURL:[NSURL URLWithString:[business.avatar url]]
                                   placeholderImage:[UIImage imageNamed:@"ic_business_default"]];
        } else {
            self.photoImageView.image = [UIImage imageNamed:@"ic_business_default"];
        }
    } @catch (NSException *exception) {
        self.photoImageView.image = [UIImage imageNamed:@"ic_business_default"];
    } @catch (id exception) {
        self.photoImageView.image = [UIImage imageNamed:@"ic_business_default"];
    }

    self.conversaIdLabel.text = [@"@" stringByAppendingString:business.conversaID];
    self.displayNameLabel.text = business.displayName;
    [self.conversaIdLabel sizeToFit];
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
    [self.conversaIdLabel sizeToFit];
}

@end
