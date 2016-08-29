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

@implementation CustomSearchCell

- (void)awakeFromNib {
    _photoImageView.layer.cornerRadius = _photoImageView.frame.size.width / 2;
}

- (void)configureCellWith:(Business *)business {
    self.business = business;
    
    self.photoImageView.image = [UIImage imageNamed:@"business_default"];    
    self.photoImageView.file = business.avatar;
    [self.photoImageView loadInBackground];
    self.conversaIdLabel.text = [@"@" stringByAppendingString:business.conversaID];
    self.usernameLabel.text = business.displayName;
    [self.conversaIdLabel sizeToFit];
}

- (void)configureCellWith:(Business *)business withAvatar:(UIImage *)avatar {
    self.business = business;
    self.photoImageView.image = avatar;
    self.conversaIdLabel.text = [@"@" stringByAppendingString:business.conversaID];
    self.usernameLabel.text = business.displayName;
    [self.conversaIdLabel sizeToFit];
}

@end
