//
//  CustomCategoryCell.m
//  Conversa
//
//  Created by Edgar Gomez on 12/16/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "CustomCategoryCell.h"

#import "nCategory.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface CustomCategoryCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;

@end

@implementation CustomCategoryCell

- (void)configureCellWith:(nCategory *)category {
    self.category = category;

    [self.avatar sd_setImageWithURL:[NSURL URLWithString:[category getAvatarUrl]]
                 placeholderImage:[UIImage imageNamed:@"business_default_light"]];

    self.nameLabel.text = [category getCategoryName];
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}


@end