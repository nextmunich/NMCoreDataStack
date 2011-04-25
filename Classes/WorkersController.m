//
//  WorkersController.m
//  NMCoreDataStack
//
//  Created by Benjamin Broll on 15.04.11.
//  Copyright 2011 NEXT Munich. The App Agency. All rights reserved.
//

#import "WorkersController.h"

#import "DataItem.h"
#import "Worker.h"


@interface WorkersController (Private)

- (void)postInit;

@end


@implementation WorkersController

#pragma mark Properties

@synthesize workerCountLabel;


#pragma mark UI Updates

- (void)updateUI {
	// we're on the main thread thus we have to use the mainThreadContext if we
	// need to perform any quick core data work
	NSManagedObjectContext *ctx = [stack mainThreadContext];
	
	NSFetchRequest *fetch = [[[NSFetchRequest alloc] init] autorelease];
	[fetch setEntity:[stack entityDescriptionForName:@"DataItem"]];
	
	// Try to find the amount of DataItem objects stored in the DB. Notice that
	// the main thread context is never re-created but is still kept in-synch
	// with changes performed by the workers.
	NSError *error;
	NSUInteger count = [ctx countForFetchRequest:fetch error:&error];
	
	// update the UI with the current information
	workerCountLabel.text = [NSString stringWithFormat:@"%d (%d)", numberOfWorkers, count];
}


#pragma mark Button Actions

- (IBAction)scheduleWork {
	
	static NSInteger currentIndex = 0;
	static NSInteger numberOfIndices = 10;
	
	numberOfWorkers++;
	[self updateUI];
	
	// create a worker
	Worker *w = [[[Worker alloc] init] autorelease];
	w.startIndex = currentIndex;
	w.endIndex = currentIndex+numberOfIndices-1;
	
	// launch the worker on a background thread
	[stack performWorkerInBackground:w notifyingDelegateOnMainThread:self];
	
	currentIndex += numberOfIndices;
}


#pragma mark Core Data Worker Delegate

- (void)workerDidFinish:(id<NMCoreDataWorker>)worker {
	numberOfWorkers--;
	
	// UI may be updated here since we receive the callback on the main thread
	[self updateUI];
}


#pragma mark Memory & View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		[self postInit];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		[self postInit];
	}
	
	return self;
}


- (void)postInit {
	// initialize the directory to the database
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:@"dataitems_sample1.db"];
	
	// clean database
	NSError *error;
	NSFileManager *mgr = [NSFileManager defaultManager];
	if ([mgr fileExistsAtPath:databasePath]
		&& ![[NSFileManager defaultManager] removeItemAtPath:databasePath error:&error]) {
		
		NSLog(@"error removing current database. error: %@", error);
	}
	 // initialize core data stack and allow a maximum of 10 workers to run concurrently
	stack = [[NMCoreDataStack alloc] initWithDatabaseURL:[NSURL fileURLWithPath:databasePath]];
	[stack setMaxConcurrentWorkerCount:10];
}


- (void)unloadViewReferences {
	self.workerCountLabel = nil;
}


- (void)viewDidUnload {
	[self unloadViewReferences];
	
	[super viewDidUnload];
}

- (void)dealloc {
	[self unloadViewReferences];
	
	[stack release];
	
	[super dealloc];
}

@end
