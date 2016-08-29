//
//  PFSearchQueue.h
//  Conversa
//
//  Created by Edgar Gomez on 2/10/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

@import Foundation;
#import <Parse/Parse.h>

typedef void (^PFSearchCompletionBlock)(NSArray *objects);

/**
 * The PFSearchQueue class assists in UI based searches,
 * where the database is tasked in keeping up with the user's typing.
 *
 * Here's how it works:
 * - The user enters a new character in the search field.
 * - You enqueue the proper query, and asynchronously start the search using performSearchWithQueue.
 * - Rather than performing every single search (for every single enqueued query),
 *   this class performs the most recent query.
 *
 * This class is thread-safe.
 **/
@interface PFSearchQueue : NSObject

+ (PFSearchQueue *)searchInstance;

/**
 * Use this method to enqueue the proper query.
 * This is generally done when the search field changes (due to user interaction).
 **/
- (void)enqueuePFQuery:(PFQuery *)query;


- (void)clearPFQueryQueue;

@end