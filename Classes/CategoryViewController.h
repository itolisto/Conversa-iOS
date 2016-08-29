//
//  CategoriesViewController.h
//  Conversa
//
//  Created by Edgar Gomez on 12/14/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

@import UIKit;
#import <Parse/Parse.h>
#import <Bolts/Bolts.h>
#import <ParseUI/ParseUI.h>
#import "CustomPFQueryTableViewController.h"

@interface CategoryViewController : CustomPFQueryTableViewController

@property (nonatomic, strong) NSString *categoryId;

@end