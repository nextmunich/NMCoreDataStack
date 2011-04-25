//
//  Worker.m
//  NMCoreDataStack
//
//  Created by Benjamin Broll on 26.04.11.
//  Copyright 2011 NEXT Munich. The App Agency. All rights reserved.
//

#import "Worker.h"

#import "DataItem.h"


@implementation Worker

@synthesize startIndex, endIndex;

- (void)performWorkWithManager:(NMCoreDataStack *)stack context:(NSManagedObjectContext *)context {
	// log start of background work
	NSLog(@"worker starting for index: %d", startIndex);
	
	for (NSInteger i = startIndex; i <= endIndex; i++) {
		// insert and customize a new data item
		DataItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"DataItem" inManagedObjectContext:context];
		
		item.title = [NSString stringWithFormat:@"Item %d", i];
		item.content = [NSString stringWithFormat:@"Content %d", i];
		
		[NSThread sleepForTimeInterval:0.5];
		
		// save the context after every 100 inserts
		if (i % 10 == 0) {
			NSError *error;
			if (![context save:&error]) {
				NSLog(@"error creating saving context in worker '%@'. error: %@", self, error);
			} else {
				NSLog(@"worker successfully saved context after inserting index '%d'", i);
			}

		}
	}
	
	// save the context at the end of the loop
	NSError *error;
	if (![context save:&error]) {
		NSLog(@"error creating saving context in worker '%@'. error: %@", self, error);
	} else {
		NSLog(@"worker successfully saved context after all items have been inserted");
	}
}

@end
