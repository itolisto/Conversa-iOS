//
//  CustomBusinessCell.h
//  Conversa
//
//  Created by Edgar Gomez on 12/2/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

@import UIKit;
@class YapContact;
@class YapSearch;

@interface CustomBusinessCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *conversaIdLabel;
@property (weak, nonatomic) IBOutlet UIImageView *verifiedImageView;

@property (strong, nonatomic) YapContact *business;
@property (strong, nonatomic) YapSearch *yapbusiness;

- (void)configureCellWith:(YapContact *)business;
- (void)configureCellWithYap:(YapSearch *)business;

@end
