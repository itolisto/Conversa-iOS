//
//  CustomCategoryCell.m
//  Conversa
//
//  Created by Edgar Gomez on 12/16/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "CustomCategoryCell.h"

#import "bCategory.h"

@interface CustomCategoryCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet PFImageView *avatar;

@end

@implementation CustomCategoryCell

- (void)configureCellWith:(bCategory *)category {
    self.category = category;
    
    if (category.thumbnail) {
        self.avatar.file = category.thumbnail;
    } else {
        self.avatar.image = [UIImage imageNamed:@"business_default_light"];
    }
    
    self.nameLabel.text = [category getCategoryName];
    [self.avatar loadInBackground];
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}


@end