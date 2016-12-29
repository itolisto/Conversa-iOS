//
//  ProfileDialogViewController.h
//  Conversa
//
//  Created by Edgar Gomez on 11/28/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

@import UIKit;
@class Business;
@class YapSearch;

@interface ProfileDialogViewController : UIViewController <UIGestureRecognizerDelegate>

@property(strong, nonatomic) Business *business;
@property(strong, nonatomic) YapSearch *yapbusiness;
@property(assign, nonatomic) BOOL enable;

@end
