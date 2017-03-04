//
//  BaseTableViewController.h
//  ConversaManager
//
//  Created by Edgar Gomez on 12/19/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

@import UIKit;

#import "YapMessage.h"
#import "YapContact.h"
#import "SettingsKeys.h"
#import "Reachability.h"
#import "DatabaseManager.h"
#import "CustomAblyRealtime.h"

#import "Conversa-Swift.h"

@interface BaseTableViewController : UITableViewController <ConversationListener>

- (UIViewController *)topViewController;
- (void)noConnection;
- (void)yesconnection;
@property(nonatomic, strong) Reachability *networkReachability;

@end
