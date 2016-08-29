//
//  PopularSearch.h
//  Conversa
//
//  Created by Edgar Gomez on 2/15/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

@import Foundation;
#import "Business.h"
#import <Parse/Parse.h>

@interface PopularSearch : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic, strong) Business *business;

@end