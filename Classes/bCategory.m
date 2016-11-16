//
//  Category.m
//  Conversa
//
//  Created by Edgar Gomez on 12/15/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "bCategory.h"

#import "Constants.h"
#import <Parse/PFObject+Subclass.h>

@implementation bCategory

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return kClassCategory;
}

@end