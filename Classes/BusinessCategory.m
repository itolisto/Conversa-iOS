//
//  BusinessCategory.m
//  Conversa
//
//  Created by Edgar Gomez on 2/14/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

#import "BusinessCategory.h"

#import "Constants.h"
#import <Parse/PFObject+Subclass.h>

@implementation BusinessCategory

@dynamic business;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return kClassBusinessCategory;
}

@end