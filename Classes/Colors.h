//
//  OTRColors.h
//  Off the Record
//
//  Created by David Chiles on 1/27/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

@import UIKit;

@interface Colors : NSObject

+ (UIColor*)greenNavbar;
+ (UIColor*)whiteNavbar;
+ (UIColor*)outgoing;
+ (UIColor*)incoming;
+ (UIColor*)green;
+ (UIColor*)black;
+ (UIColor*)white;
+ (UIColor*)blue;
+ (UIColor*)red;
+ (UIColor*)searchBar;

+ (UIColor*)profileOnline;
+ (UIColor*)profileOffline;
+ (UIColor*)profileAway;

+ (UIColor*)darkerGreen;
+ (UIColor*)secondaryGreen;

+ (UIColor*)darkenColor:(UIColor*)color withValue:(CGFloat)value;

@end
