//
//  CustomHeaderProfileCell.h
//  Conversa
//
//  Created by Edgar Gomez on 3/4/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

@import UIKit;
@class Business;
#import "Conversa-Swift.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface CustomHeaderProfileCell : UITableViewCell

- (void)configureHeaderWith:(Business *)business withGoChatEnable:(BOOL)enable;
- (void)configureHeaderWith:(NSDictionary *)business chatEnable:(BOOL)enable;

@end
