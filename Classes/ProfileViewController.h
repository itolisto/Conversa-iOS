//
//  ProfileViewController.h
//  Conversa
//
//  Created by Edgar Gomez on 3/5/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

@import UIKit;
@class Business;

@interface ProfileViewController : UIViewController

@property(strong, nonatomic) Business *business;
@property(assign, nonatomic) bool enable;

@end
