//
//  CustomCategoryCell.h
//  Conversa
//
//  Created by Edgar Gomez on 12/16/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

@import UIKit;
@class nCategory;
#import <ParseUI/ParseUI.h>

@interface CustomCategoryCell : PFTableViewCell

@property (weak, nonatomic) nCategory *category;
- (void)configureCellWith:(nCategory *)category;

@end