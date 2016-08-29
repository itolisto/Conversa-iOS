//
//  PopularSearch.m
//  Conversa
//
//  Created by Edgar Gomez on 2/15/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

#import "PopularSearch.h"

#import "Constants.h"
#import <Parse/PFObject+Subclass.h>

@implementation PopularSearch

@dynamic business;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return kClassStatistics;
}

@end