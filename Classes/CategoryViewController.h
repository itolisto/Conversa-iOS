//
//  CategoriesViewController.h
//  Conversa
//
//  Created by Edgar Gomez on 12/14/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

@import UIKit;

#import "BaseViewController.h"

@interface CategoryViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *categoryId;
@property (nonatomic, assign) BOOL custom;

@end
