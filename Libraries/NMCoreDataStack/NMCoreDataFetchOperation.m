//
//  NMCoreDataFetchOperation.m
//  NMCoreDataStack
//
//  Created by Benjamin Broll on 15.04.11.
//  Copyright 2011 NEXT Munich. The App Agency. All rights reserved.
//

/*
 * The BSD License
 * http://www.opensource.org/licenses/bsd-license.php
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * - Neither the name of NEXT Munich GmbH nor the names of its contributors may
 *   be used to endorse or promote products derived from this software without
 *   specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

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
