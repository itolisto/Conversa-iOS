//
//  CustomCategoryCell.h
//  Conversa
//
//  Created by Edgar Gomez on 12/16/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

@import UIKit;
@class bCategory;
#import <ParseUI/ParseUI.h>

@interface CustomCategoryCell : PFTableViewCell

@property (weak, nonatomic) bCategory *category;
- (void)configureCellWith:(bCategory *)category;

@end