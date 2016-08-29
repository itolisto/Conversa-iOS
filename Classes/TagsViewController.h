//
//  CategoryViewController.h
//  Conversa
//
//  Created by Edgar Gomez on 12/14/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

@import UIKit;
#import "CustomPFQueryTableViewController.h"

@interface TagsViewController : CustomPFQueryTableViewController

- (void) runQueryWithParameter:(NSString *)search;

@end