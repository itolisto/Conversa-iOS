//
//  CategoriesViewController.h
//  Conversa
//
//  Created by Edgar Gomez on 12/14/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

@import UIKit;
@import Parse;

@interface CategoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *categoryId;

@end