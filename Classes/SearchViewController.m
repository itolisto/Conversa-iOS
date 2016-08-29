//
//  SearchViewController.m
//  Conversa
//
//  Created by Edgar Gomez on 29/01/16.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "SearchViewController.h"

#import "Log.h"
#import "Colors.h"
#import "Constants.h"
#import "TagsViewController.h"
#import "RecentViewController.h"
#import "PopularViewController.h"
#import "CategoriesViewController.h"

@interface SearchViewController ()

@property (nonatomic) CAPSPageMenu *pageMenu;
@property (nonatomic, assign) BOOL reload;

@end

@implementation SearchViewController

#pragma mark - Lifecycle Methods -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.reload = NO;
    
    RecentViewController *controller1  = [[RecentViewController alloc]initWithNibName:@"RecentViewController"
                                                                              bundle:nil];
    controller1.title = NSLocalizedString(@"search_view_recent_tab", nil);
    PopularViewController *controller2 = [[PopularViewController alloc]initWithNibName:@"PopularViewController"
                                                                                bundle:nil];
    controller2.title = NSLocalizedString(@"search_view_popular_tab", nil);
    TagsViewController *controller3    = [[TagsViewController alloc]initWithNibName:@"TagsViewController"
                                                                                 bundle:nil];
    controller3.title = NSLocalizedString(@"search_view_tag_tab", nil);
    
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [Colors whiteColor],
                                 CAPSPageMenuOptionSelectionIndicatorColor: [Colors greenColor],
                                 CAPSPageMenuOptionUnselectedMenuItemLabelColor: [Colors blackColor],
                                 CAPSPageMenuOptionSelectedMenuItemLabelColor: [Colors greenColor],
                                 CAPSPageMenuOptionEnableHorizontalBounce: @(YES),
                                 CAPSPageMenuOptionMenuItemSeparatorWidth: @(4.3),
                                 CAPSPageMenuOptionUseMenuLikeSegmentedControl: @(YES),
                                 CAPSPageMenuOptionMenuItemSeparatorPercentageHeight: @(0.1),
                                 CAPSPageMenuOptionMenuHeight: @(40.0),
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:@"HelveticaNeue" size:11.0]
                                 };
    
    _pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:@[controller2, controller1, controller3]
                                                        frame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)
                                                      options:parameters];
    [self.view addSubview:_pageMenu.view];
    
    _pageMenu.delegate = self;
}

#pragma mark - CAPSPageMenuDelegate Method -

- (void)willMoveToPage:(UIViewController *)controller index:(NSInteger)index {
    __weak typeof(UIViewController *)wController = controller;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *search = nil;
        CategoriesViewController *cController = nil;
        
        for (UIViewController*vc in [self.navigationController viewControllers]) {
            if ([vc isKindOfClass: [CategoriesViewController class]]){
                cController = ((CategoriesViewController *) vc);
                search      = cController.searchController.searchBar.text;
            }
        }
        
        typeof(UIViewController *)sController = wController;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (sController) {
                switch (index) {
                    case 0:{
                        cController.searchController.searchBar.placeholder = NSLocalizedString(@"search_searchbar_popular_placeholder", nil);
                        [((PopularViewController *) sController) runQueryWithParameter:search];
                        break;
                    }
                    case 1: {
                        cController.searchController.searchBar.placeholder = NSLocalizedString(@"search_searchbar_recent_placeholder", nil);
                        [((RecentViewController *) sController) runQueryWithParameter:search];
                        break;
                    }
                    default: {
                        cController.searchController.searchBar.placeholder = NSLocalizedString(@"search_searchbar_tag_placeholder", nil);
                        [((TagsViewController *) sController) runQueryWithParameter:search];
                        break;
                    }
                }
            }
        });
    });
}

@end