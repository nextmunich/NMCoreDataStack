//
//  NMCoreDataFetchOperation.m
//  NMCoreDataStack
//
//  Created by Benjamin Broll on 15.04.11.
//  Copyright 2011 NEXT Munich. The App Agency. All rights reserved.
//

#import "NMCoreDataFetchOperation.h"

#import "NMCoreDataStack.h"
#import "NMCoreDataStack+Private.h"
#import "NMCoreDataUtilities.h"


@interface NMCoreDataFetchOperation (Private)

- (void)notifyDelegateWithResultObjectIDs:(NSArray *)objectIDs;
- (void)notifyDelegateWithError:(NSError *)error;

@end



@implementation NMCoreDataFetchOperation

@synthesize stack;
@synthesize request;
@synthesize delegate;


#pragma mark NSOperation Lifecycle

- (void)main {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSManagedObjectContext *context = [stack borrowNewContext];
	
	NSError *error = nil;
	NSArray *result = [context executeFetchRequest:request error:&error];
	
	if (![self isCancelled]) {
		if (error == nil) {
			[self performSelectorOnMainThread:@selector(notifyDelegateWithResultObjectIDs:)
								   withObject:[NMCoreDataUtilities objectIDsForObjects:result]
								waitUntilDone:YES];
		} else {
			[self performSelectorOnMainThread:@selector(notifyDelegateWithError:) withObject:error waitUntilDone:YES];
		}
	}
	
	[stack returnContext:context];
	[pool release];
}


#pragma mark Delegate Helpers

- (void)notifyDelegateWithResultObjectIDs:(NSArray *)objectIDs {
	NSManagedObjectContext *context = [stack mainThreadContext];
	NSArray *objects = [NMCoreDataUtilities objectsForObjectIDs:objectIDs inContext:context];
	
	if (![self isCancelled]) [delegate fetchRequest:request didFetchObjects:objects];
}

- (void)notifyDelegateWithError:(NSError *)error {
	if (![self isCancelled]) [delegate fetchRequest:request didFailWithError:error];
}


#pragma mark Dealloc

- (void)dealloc {
	self.stack = nil;
	self.request = nil;
	
	[super dealloc];
}

@end
