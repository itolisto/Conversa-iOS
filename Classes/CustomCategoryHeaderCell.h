//
//  CustomCategoryHeaderCell.h
//  Conversa
//
//  Created by Edgar Gomez on 11/12/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

@import UIKit;
@class nHeaderTitle;
#import <ParseUI/ParseUI.h>

@interface CustomCategoryHeaderCell : PFTableViewCell

- (void)configureCellWith:(nHeaderTitle *)category;

@end