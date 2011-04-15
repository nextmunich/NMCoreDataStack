//
//  NMCoreDataWorkerOperation.m
//  NMCoreDataStack
//
//  Created by Benjamin Broll on 15.04.11.
//  Copyright 2011 NEXT Munich. The App Agency. All rights reserved.
//

#import "NMCoreDataWorkerOperation.h"

#import "NMCoreDataStack.h"
#import "NMCoreDataStack+Private.h"



@interface NMCoreDataWorkerOperation (Private)

- (void)notifyDelegate;

@end



@implementation NMCoreDataWorkerOperation

@synthesize stack;
@synthesize worker;
@synthesize delegate;


#pragma mark NSOperation Lifecycle

- (void)main {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSManagedObjectContext *context = [stack borrowNewContext];
	
	[worker performWorkWithManager:stack context:context];
	[self performSelectorOnMainThread:@selector(notifyDelegate) withObject:nil waitUntilDone:YES];
	
	[stack returnContext:context];
	[pool release];
}


#pragma mark Delegate Helpers

- (void)notifyDelegate {
	if (![self isCancelled]) [delegate workerDidFinish:worker];
}


#pragma mark Dealloc

- (void)dealloc {
	self.stack = nil;
	self.worker = nil;
	
	[super dealloc];
}

@end
