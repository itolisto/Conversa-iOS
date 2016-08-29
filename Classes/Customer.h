//
//  Customer.h
//  Conversa
//
//  Created by Edgar Gomez on 12/15/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

@import Foundation;
#import <Parse/Parse.h>

@interface Customer : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic, assign) BOOL gender;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *status;

@end
