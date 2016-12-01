//
//  ProfileDialogViewController.h
//  Conversa
//
//  Created by Edgar Gomez on 11/28/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

@import UIKit;
@class Business;
#import "MZFormSheetPresentationViewController.h"

@interface ProfileDialogViewController : UIViewController

@property(strong, nonatomic) Business *business;
@property(assign, nonatomic) bool enable;

+ (void)controller:(UIViewController*)fromController business:(Business*)business enable:(BOOL)enable device:(NSString*)machine;

@end