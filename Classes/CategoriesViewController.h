//
//  CategoriesViewController.h
//  Conversa
//
//  Created by Edgar Gomez on 12/14/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

@import UIKit;
#import "CustomPFQueryViewController.h"

@interface CategoriesViewController : CustomPFQueryViewController <UISearchBarDelegate>

@property (strong, nonatomic) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end