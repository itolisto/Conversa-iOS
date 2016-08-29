//
//  CustomSearchCell.h
//  Conversa
//
//  Created by Edgar Gomez on 01/29/16.
//  Copyright © 2015 Conversa. All rights reserved.
//

@import UIKit;
@class Business;
#import <ParseUI/ParseUI.h>

@interface CustomSearchCell : UITableViewCell

@property (nonatomic, weak) IBOutlet PFImageView *photoImageView;
@property (nonatomic, weak) IBOutlet UILabel *conversaIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *verifiedImageView;

@property (strong, nonatomic) Business *business;
- (void)configureCellWith:(Business *)business;
- (void)configureCellWith:(Business *)business withAvatar:(UIImage *)avatar;

@end
