//
//  CustomChatButton.h
//  Conversa
//
//  Created by Edgar Gomez on 12/19/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

/*
 * Custom button needed to perform segue and have a reference to the actual business
 * pressed
 */

@import UIKit;
@class Business;

@interface CustomChatButton : UIButton

@property (strong, nonatomic) Business *business;

@end
