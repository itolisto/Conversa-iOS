//
//  PFSearchQueue.m
//  Conversa
//
//  Created by Edgar Gomez on 2/10/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

#import "PFSearchQueue.h"

@implementation PFSearchQueue
{
    NSMutableArray *queue;
}

+ (PFSearchQueue *)searchInstance {
    __strong static PFSearchQueue *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PFSearchQueue alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if ((self = [super init]))
    {
        queue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)enqueuePFQuery:(PFQuery *)query
{
    @synchronized (self->queue) {
        // Default parameters
        query.limit = 25;
        query.skip = 0;
        // Enqueu query
        if ([self->queue count]) {
            [((PFQuery *)[queue firstObject]) cancel];
            [self->queue replaceObjectAtIndex:0 withObject:query];
        } else {
            [self->queue insertObject:query atIndex:0];
        }
    }
}

- (void)clearPFQueryQueue {
    @synchronized (self->queue) {
        for (PFQuery*query in self->queue) {
            [query cancel];
        }
        [self->queue removeAllObjects];
    }
}

@end
