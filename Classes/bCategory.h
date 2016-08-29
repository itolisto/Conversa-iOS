//
//  Category.h
//  Conversa
//
//  Created by Edgar Gomez on 12/15/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

@import Foundation;
#import <Parse/Parse.h>

@interface bCategory : PFObject<PFSubclassing>

+ (NSString *)parseClassName;
- (NSString *)getCategoryName;

@property (nonatomic, strong) PFFile   *thumbnail;

@end
