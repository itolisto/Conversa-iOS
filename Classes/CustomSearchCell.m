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
#import "YapContact.h"
#import "NSFileManager+Conversa.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation CustomSearchCell

- (void)awakeFromNib {
    _photoImageView.layer.cornerRadius = _photoImageView.frame.size.width / 2;
}

- (void)configureCellWith:(Business *)business {
    self.business = business;

    if (business.avatar) {
        [self.photoImageView sd_setImageWithURL:[NSURL URLWithString:[business.avatar url]]
                       placeholderImage:[UIImage imageNamed:@"ic_business_default_light"]];
    } else {
        self.photoImageView.image = [UIImage imageNamed:@"ic_business_default_light"];
    }

    self.conversaIdLabel.text = [@"@" stringByAppendingString:business.conversaID];
    self.displayNameLabel.text = business.displayName;
    [self.conversaIdLabel sizeToFit];
}

- (void)configureCellWith:(Business *)business withAvatar:(UIImage *)avatar {
    self.business = business;

    self.photoImageView.image = avatar;
    self.conversaIdLabel.text = [@"@" stringByAppendingString:business.conversaID];
    self.displayNameLabel.text = business.displayName;
    [self.conversaIdLabel sizeToFit];
}

@end
