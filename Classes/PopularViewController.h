//
//  PopularViewController.h
//  Conversa
//
//  Created by Edgar Gomez on 1/28/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

@import UIKit;
#import "CustomPFQueryTableViewController.h"

@interface PopularViewController : CustomPFQueryTableViewController

- (void) runQueryWithParameter:(NSString *)search;

@end
