//
//  nHeaderTitle.h
//  Conversa
//
//  Created by Edgar Gomez on 11/12/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface nHeaderTitle : NSObject

@property (strong, nonatomic) NSString *headerName;
@property (assign, nonatomic) NSInteger relevance;

- (NSString *)getHeaderName;
- (NSInteger)getRelevance;

@end