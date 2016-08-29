/*
 *  Copyright (c) 2014, Parse, LLC. All rights reserved.
 *
 *  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
 *  copy, modify, and distribute this software in source code or binary form for use
 *  in connection with the web services and APIs provided by Parse.
 *
 *  As with any software that integrates with the Parse platform, your use of
 *  this software is subject to the Parse Terms of Service
 *  [https://www.parse.com/about/terms]. This copyright notice shall be
 *  included in all copies or substantial portions of the software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 *  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 *  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 *  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 *  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */
//
//  CustomPFQueryViewController.h
//  Conversa
//
//  Created by Edgar Gomez on 2/10/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

@import UIKit;
#import <Parse/PFConstants.h>
#import <ParseUI/ParseUIConstants.h>

NS_ASSUME_NONNULL_BEGIN

@class BFTask<__covariant BFGenericType>;
@class PFObject;
@class PFQuery;
@class PFTableViewCell;

@interface CustomPFQueryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

///--------------------------------------
/// @name Configuring Behavior
///--------------------------------------

/**
 The refresh control associated to table view if the last one is not null
 */
@property (nonatomic, strong, nullable) UIRefreshControl *refreshControl;

/**
 The table view associated to this view
 */
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/**
 Whether the table should use the default loading view. Default - `YES`.
 */
@property (nonatomic, assign) IBInspectable BOOL loadingViewEnabled;

/**
 Whether the table should use the built-in pull-to-refresh feature. Default - `YES`.
 */
@property (nonatomic, assign) IBInspectable BOOL pullToRefreshEnabled;

/**
 Whether the table should use the built-in pagination feature. Default - `YES`.
 */
@property (nonatomic, assign) IBInspectable BOOL paginationEnabled;

/**
 The number of objects to show per page. Default - `25`.
 */
@property (nonatomic, assign) IBInspectable NSUInteger objectsPerPage;

/**
 Whether the table is actively loading new data from the server.
 */
@property (nonatomic, assign, getter=isLoading) BOOL loading;

///--------------------------------------
/// @name Responding to Events
///--------------------------------------

/**
 Called when objects will loaded from Parse. If you override this method, you must
 call [super objectsWillLoad] in your implementation.
 */
- (void)objectsWillLoad;

/**
 Called when objects have loaded from Parse. If you override this method, you must
 call [super objectsDidLoad:] in your implementation.
 @param error The Parse error from running the PFQuery, if there was any.
 */
- (void)objectsDidLoad:(nullable NSError *)error;

///--------------------------------------
/// @name Accessing Results
///--------------------------------------

/**
 The array of instances of `PFObject` that is used as a data source.
 */
@property (nullable, nonatomic, copy, readonly) NSArray<__kindof PFObject *> *objects;

@end

NS_ASSUME_NONNULL_END