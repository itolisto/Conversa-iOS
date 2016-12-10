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
@property (weak, nonatomic) IBOutlet UIView *dividerView;

@end

@implementation CustomCategoryCell

- (void)configureCellWith:(nCategory *)category hideView:(bool)hideView {
    self.category = category;

    [self.avatar sd_setImageWithURL:[NSURL URLWithString:[category getAvatarUrl]]
                 placeholderImage:[UIImage imageNamed:@"ic_business_default"]];

    self.nameLabel.text = [category getCategoryName];

    if (hideView) {
        self.dividerView.hidden = YES;
    } else {
        self.dividerView.hidden = NO;
    }
}

@end
