//
//  CategoriesViewController.h
//  Conversa
//
//  Created by Edgar Gomez on 12/14/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

@import UIKit;
@import Parse;

@interface CategoriesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

/**
 The refresh control associated to table view if the last one is not null
 */
@property (nonatomic, strong, nullable) UIRefreshControl *refreshControl;

/**
 The table view associated to this view
 */
@property (weak, nonatomic, nullable) IBOutlet UITableView *tableView;

/**
 Whether the table is actively loading new data from the server.
 */
@property (nonatomic, assign, getter=isLoading) BOOL loading;

@property (nonatomic, assign) BOOL searchMode;

@property (strong, nonatomic, nonnull) UISearchController *searchController;
@property (weak, nonatomic, nullable) IBOutlet UISearchBar *searchBar;

@end
