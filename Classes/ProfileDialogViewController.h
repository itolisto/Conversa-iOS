//
//  ProfileDialogViewController.h
//  Conversa
//
//  Created by Edgar Gomez on 11/28/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

@import UIKit;
@class YapContact;
@class YapSearch;

@interface ProfileDialogViewController : UIViewController <UIGestureRecognizerDelegate>

@property(strong, nonatomic) NSString *objectId;
@property(strong, nonatomic) NSString *avatarUrl;
@property(strong, nonatomic) NSString *displayName;
@property(strong, nonatomic) NSString *conversaID;
@property(assign, nonatomic) BOOL enable;

@end
