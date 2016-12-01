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
#import "MZFormSheetPresentationViewController.h"

@interface ProfileDialogViewController : UIViewController

@property(strong, nonatomic) Business *business;
@property(strong, nonatomic) YapSearch *yapbusiness;
@property(assign, nonatomic) bool enable;

+ (void)controller:(UIViewController*)fromController
          business:(Business*)business
       yapbusiness:(YapSearch*)yapbusiness
            enable:(BOOL)enable
            device:(NSString*)machine;

@end
