//
//  LoginHandler.h
//  Conversa
//
//  Created by Edgar Gomez on 12/23/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

@import UIKit;
@class Account;
@class FIRUser;

@interface LoginHandler : NSObject

+ (void) proccessLoginForAccount:(FIRUser *)account fromViewController:(UIViewController*)controller;

@end
