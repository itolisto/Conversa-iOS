//
//  CustomInfoCell.h
//  Conversa
//
//  Created by Edgar Gomez on 2/27/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

@import UIKit;
#import <TTTAttributedLabel/TTTAttributedLabel.h>

@interface CustomInfoCell : UITableViewCell <TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UILabel *optionTitle;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *optionDescription;

- (void)configureCellWith:(NSDictionary *)option;

@end
