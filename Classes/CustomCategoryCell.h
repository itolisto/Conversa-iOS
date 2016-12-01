//
//  CustomCategoryCell.h
//  Conversa
//
//  Created by Edgar Gomez on 12/16/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

@import UIKit;
@class nCategory;

@interface CustomCategoryCell : UITableViewCell

@property (weak, nonatomic) nCategory *category;
- (void)configureCellWith:(nCategory *)category hideView:(bool)hideView;

@end
