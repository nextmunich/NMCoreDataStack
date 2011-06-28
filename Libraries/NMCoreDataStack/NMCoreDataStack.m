//
//  NMCoreDataStack.m
//  NMCoreDataStack
//
//  Created by Benjamin Broll on 27.01.11.
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

#import "NMCoreDataStack.h"

#import "NMCoreDataFetchOperation.h"
#import "NMCoreDataStack+Private.h"
#import "NMCoreDataUtilities.h"
#import "NMCoreDataWorkerOperation.h"


NSString* const AdditionalContextsSynchronizationString = @"AdditionalContextsSynchronizationString";


#pragma mark -

@implementation NMCoreDataStack

#pragma mark Properties

- (void)setMaxConcurrentFetchCount:(NSInteger)count {
	[fetchQueue setMaxConcurrentOperationCount:count];
}

- (NSInteger)maxConcurrentFetchCount {
	return [fetchQueue maxConcurrentOperationCount];
}

- (void)setMaxConcurrentWorkerCount:(NSInteger)count {
	[workerQueue setMaxConcurrentOperationCount:count];
}

- (NSInteger)maxConcurrentWorkerCount {
	return [workerQueue maxConcurrentOperationCount];
}


#pragma mark Managed Objects

- (NSEntityDescription *)entityDescriptionForName:(NSString *)name {
	return [NSEntityDescription entityForName:name inManagedObjectContext:[self mainThreadContext]];
}


#pragma mark Fetching

- (void)fetchInBackground:(NSFetchRequest *)request notifyingDelegateOnMainThread:(id<NMCoreDataFetchDelegate>)delegate {
	NMCoreDataFetchOperation *operation = [[[NMCoreDataFetchOperation alloc] init] autorelease];
	operation.stack = self;
	operation.request = request;
	operation.delegate = delegate;
	
	[fetchQueue addOperation:operation];
}

- (void)fetchTemplateInBackground:(NSString *)templateName withVariables:(NSDictionary *)variables notifyingDelegateOnMainThread:(id<NMCoreDataFetchDelegate>)delegate {
	NSFetchRequest* fetchRequest = [managedObjectModel fetchRequestFromTemplateWithName:templateName substitutionVariables:variables];
	
	[self fetchInBackground:fetchRequest notifyingDelegateOnMainThread:delegate];
}

- (void)cancelPendingFetches {
	[fetchQueue cancelAllOperations];
}


#pragma mark Arbitrary Work

- (void)performWorkerInBackground:(id<NMCoreDataWorker>)worker notifyingDelegateOnMainThread:(id<NMCoreDataWorkerDelegate>)delegate {
	NMCoreDataWorkerOperation *operation = [[[NMCoreDataWorkerOperation alloc] init] autorelease];
	operation.stack = self;
	operation.worker = worker;
	operation.delegate = delegate;
	
	[workerQueue addOperation:operation];
}


#pragma mark Utilities

- (NSFetchRequest *)fetchRequestForTemplate:(NSString *)templateName withVariables:(NSDictionary *)variables {
	return [managedObjectModel fetchRequestFromTemplateWithName:templateName substitutionVariables:variables];
}


#pragma mark Accessing Contexts

- (NSManagedObjectContext *)mainThreadContext {
	return managedObjectContext;
}

- (NSManagedObjectContext *)borrowNewContext {
	// create the context
	NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
	[context setPersistentStoreCoordinator:persistentStoreCoordinator];
	
	// register for notifications in case the context is saved
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(managedObjectContextDidSave:)
												 name:NSManagedObjectContextDidSaveNotification
											   object:context];
	
	// keep track of the context
	@synchronized (AdditionalContextsSynchronizationString) {
		[additionalContexts addObject:context];
	}
	
	// release the context now that it's being tracked
	[context release];
	
	return context;
}

- (void)returnContext:(NSManagedObjectContext *)context {
	// remove ourselves from notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:context];
	
	// delete from context listing
	@synchronized (AdditionalContextsSynchronizationString) {
		[additionalContexts removeObject:context];
	}
}


#pragma mark Managed Object Context Notifications

- (void)managedObjectContextDidSave:(NSNotification *)notification {
	// obtain the context in which the save was performed
	NSManagedObjectContext *savingContext = (NSManagedObjectContext *)[notification object];
	
	// take care of main thread context
	if (savingContext != managedObjectContext) {
		[managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
	}
	
	// take care of additional contexts
	@synchronized (AdditionalContextsSynchronizationString) {
		for (NSManagedObjectContext *context in additionalContexts) {
			if (savingContext != context) {
				[context mergeChangesFromContextDidSaveNotification:notification];
			}
		}
	}
}


#pragma mark Core Data Stack Setup

- (void)setUpCoreDataWithBundles:(NSArray *)bundles databaseURL:(NSURL *)url {
	// setup managed object model
	if (bundles == nil) {
		// will merge from main bundle
		managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
	} else {
		managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:bundles] retain];
	}
	
	// setup persistent store coordinator
	persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
	if (url != nil) {
		NSError *error = nil;
		
		NSMutableDictionary *optionsDictionary = [NSMutableDictionary dictionary];
		[optionsDictionary setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
		
		if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:optionsDictionary error:&error]) {
			// Handle the error.
			NSLog(@"COREDATA / WARN: persistentStoreCoordinator error: %@", error);
		} 
	}
	
	// setup managed object context
	if (persistentStoreCoordinator != nil) {
		[self performSelectorOnMainThread:@selector(createMainThreadContext) withObject:nil waitUntilDone:YES];
	}
	
	// verify setup
	if (managedObjectModel == nil
		|| persistentStoreCoordinator == nil
		|| managedObjectContext == nil) {
		
		NSLog(@"COREDATA / WARN: failed to initialize Core Data stack: %@, %@, %@", managedObjectModel, persistentStoreCoordinator, managedObjectContext);
	}
}

- (void)createMainThreadContext {
	// setup managed object context
	managedObjectContext = [[NSManagedObjectContext alloc] init];
	[managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
	
	// wait for save-notifications
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(managedObjectContextDidSave:)
												 name:NSManagedObjectContextDidSaveNotification
											   object:managedObjectContext];
}


#pragma mark Init & Dealloc

- (id)initWithDatabaseURL:(NSURL *)url {
	return [self initWithModelBundles:nil databaseURL:url];
}

- (id)initWithModelBundles:(NSArray *)bundles databaseURL:(NSURL *)url {
	if ((self = [super init])) {
		[self setUpCoreDataWithBundles:bundles databaseURL:url];
		
		additionalContexts = [[NSMutableArray alloc] init];
		
		fetchQueue = [[NSOperationQueue alloc] init];
		[fetchQueue setMaxConcurrentOperationCount:1];
		
		workerQueue = [[NSOperationQueue alloc] init];
		[workerQueue setMaxConcurrentOperationCount:1];
	}
	
	return self;
}

- (void)dealloc {
	[fetchQueue release];
	
	[managedObjectContext release];
	[persistentStoreCoordinator release];
	[managedObjectModel release];
	
	[super dealloc];
}

@end
