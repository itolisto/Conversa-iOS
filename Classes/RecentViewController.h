//
//  RecentTableViewController.h
//  Conversa
//
//  Created by Edgar Gomez on 1/31/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

@import UIKit;
#import "CustomPFQueryTableViewController.h"

@interface RecentViewController : CustomPFQueryTableViewController

- (void) runQueryWithParameter:(NSString *)search;

@end
