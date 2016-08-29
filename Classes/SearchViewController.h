//
//  SearchViewController.h
//  Conversa
//
//  Created by Edgar Gomez on 29/01/16.
//  Copyright © 2015 Conversa. All rights reserved.
//

@import UIKit;
#import "CAPSPageMenu.h"

@interface SearchViewController : UIViewController  <CAPSPageMenuDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) UISearchController *searchController;

@end
