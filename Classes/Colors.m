//
//  OTRColors.m
//  Off the Record
//
//  Created by David Chiles on 1/27/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import "Colors.h"

@implementation Colors

+ (UIColor*)greenNavbar {
    // green: #06f28f
    return [UIColor colorWithRed:6.0f/255.0f green:242.0f/255.0f blue:143.0f/255.0f alpha:1.0];
}

+ (UIColor*)whiteNavbar {
    // white: #F7F7F7
    return [UIColor colorWithRed:249.0f/255.0f green:249.0f/255.0f blue:249.0f/255.0f alpha:1.0];
}

+ (UIColor*)outgoing {
    // green: #69F0AE
    return [UIColor colorWithRed:105.0f/255.0f green:240.0f/255.0f blue:174.0f/255.0f alpha:1.0];
}

+ (UIColor*)incoming {
    // white: #F0F0F0
    return [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0];
}

+ (UIColor*)green {
    // green: #06f28f
    return [UIColor colorWithRed:6.0f/255.0f green:242.0f/255.0f blue:143.0f/255.0f alpha:1.0];
}

+ (UIColor*)black {
    // black: #505050
    return [UIColor colorWithRed:80.0f/255.0f green:80.0f/255.0f blue:80.0f/255.0f alpha:1.0];
}

+ (UIColor*)white {
    // white: #F7F7F7
    return [UIColor colorWithRed:249.0f/255.0f green:249.0f/255.0f blue:249.0f/255.0f alpha:1.0];
}

+ (UIColor*)blue {
    // blue: #0A7BF6
    return [UIColor colorWithRed:10.0f/255.0f green:123.0f/255.0f blue:246.0f/255.0f alpha:1.0];
}

+ (UIColor*)searchBar {
    // white: #EDEEEE
    return [UIColor colorWithRed:237.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0];
}

+ (UIColor*)profileOnline {
    // green: #00E676
    return [UIColor colorWithRed:0.0f/255.0f green:230.0f/255.0f blue:118.0f/255.0f alpha:1.0];
}

+ (UIColor*)profileOffline {
    // red: #F44336
    return [UIColor colorWithRed:244.0f/255.0f green:67.0f/255.0f blue:54.0f/255.0f alpha:1.0];
}

+ (UIColor*)profileAway {
    // orange: #FFB300
    return [UIColor colorWithRed:255.0f/255.0f green:179.0f/255.0f blue:0.0f/255.0f alpha:1.0];
}

+ (UIColor*)darkerGreen {
    // green: #00C03E
    return [UIColor colorWithRed:0.0f/255.0f green:191.0f/255.0f blue:62.0f/255.0f alpha:1.0];
}

+ (UIColor*)secondaryGreen {
    // green: #00e676
    return [UIColor colorWithRed:0.0f/255.0f green:230.0f/255.0f blue:118.0f/255.0f alpha:1.0];
}

+ (UIColor*)darkenColor:(UIColor*)color withValue:(CGFloat)value {
    NSUInteger totalComponents = CGColorGetNumberOfComponents(color.CGColor);
    BOOL isGreyscale = (totalComponents == 2) ? YES : NO;
    
    CGFloat *oldComponents = (CGFloat *)CGColorGetComponents(color.CGColor);
    CGFloat newComponents[4];
    
    if (isGreyscale) {
        newComponents[0] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[1] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[2] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[3] = oldComponents[1];
    } else {
        newComponents[0] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[1] = oldComponents[1] - value < 0.0f ? 0.0f : oldComponents[1] - value;
        newComponents[2] = oldComponents[2] - value < 0.0f ? 0.0f : oldComponents[2] - value;
        newComponents[3] = oldComponents[3];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
    CGColorSpaceRelease(colorSpace);
    
    UIColor *retColor = [UIColor colorWithCGColor:newColor];
    CGColorRelease(newColor);
    
    return retColor;
}

@end
