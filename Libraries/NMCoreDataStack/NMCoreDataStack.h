//
//  NMCoreDataStack.h
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

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>


@protocol NMCoreDataFetchDelegate;
@protocol NMCoreDataWorker;
@protocol NMCoreDataWorkerDelegate;


#pragma mark -
#pragma mark Core Data Stack

/**
 * Convenience class to facilitate working with Core Data in a multi-threaded
 * environment.
 *
 * The class manages a Core Data stack with a NSManagedObjectContext for use on
 * the main thread of the application. Additionally, it provides convenience
 * methods for fetching data on a background thread and delivering the fetch
 * results on the main thread while taking care of the thread confinement rules.
 * In addition to fetching, arbitrary work can be performed on a background
 * thread delivering a callback at the end of the work on the main thread.
 *
 * Changes to NSManagedObjectContexts saved in a background worker are
 * automatically broadcasted to any NSManagedObjectContext managed by this
 * class. Therefore, after a save, the main thread's context and any fetches
 * will make use of the new (saved) state.
 *
 * If a persistent database is used, it will be initialized with the
 * auto-migration policy enabled to allow for automatic evolvement of the
 * underlying database schema.
 */
@interface NMCoreDataStack : NSObject {

	NSManagedObjectModel* managedObjectModel;
	NSPersistentStoreCoordinator* persistentStoreCoordinator;
	
	NSManagedObjectContext* managedObjectContext;
	NSMutableArray *additionalContexts;
	
	NSOperationQueue *fetchQueue;
	NSOperationQueue *workerQueue;
	
}

#pragma mark Initialization

/**
 * Initializes the Core Data stack using the models found in the app's main
 * bundle and based on the SQLite database located at the given URL. An empty
 * database will be created in case no database exists at the given URL.
 */
- (id)initWithDatabaseURL:(NSURL *)url;

/**
 * Initializes the Core Data stack using the models found in the given bundles
 * and based on the SQLite database located at the given URL. An empty
 * database will be created in case no database exists at the given URL.
 */
- (id)initWithModelBundles:(NSArray *)bundles databaseURL:(NSURL *)url;


#pragma mark Managing Contexts

/**
 * Returns an NSManagedObjectContext which can be used on the main thread.
 */
- (NSManagedObjectContext *)mainThreadContext;



#pragma mark Fetching

/** The maximum number of concurrent background fetches. */
@property (nonatomic, assign) NSInteger maxConcurrentFetchCount;

/**
 * Performs the given NSFetchRequest on a background thread (thus not blocking the
 * main thread), calling the NMCoreDataFetchDelegate on the main thread when the
 * fetch is complete.
 *
 * Any NSManagedObject returned as the fetch result has been loaded into the
 * main thread's NSManagedObjectContext and can thus be used in UI operations.
 */
- (void)fetchInBackground:(NSFetchRequest *)request notifyingDelegateOnMainThread:(id<NMCoreDataFetchDelegate>)delegate;

/**
 * Performs a fetch using the template with the given name and substitution
 * variables on a background thread, calling the NMCoreDataFetchDelegate on the
 * main thread when the fetch is complete.
 *
 * Any NSManagedObject returned as the fetch result has been loaded into the
 * main thread's NSManagedObjectContext and can thus be used in UI operations.
 */
- (void)fetchTemplateInBackground:(NSString *)templateName
					withVariables:(NSDictionary *)variables
	notifyingDelegateOnMainThread:(id<NMCoreDataFetchDelegate>)delegate;

/**
 * Cancels any pending fetches.
 *
 * None of the cancelled fetches will call their respective delegates.
 */
- (void)cancelPendingFetches;


#pragma mark Arbitrary Work with Contexts

/** The maximum number of concurrent workers that are allowed to execute. */
@property (nonatomic, assign) NSInteger maxConcurrentWorkerCount;

/**
 * Calls the workers -performWorkWithManager:context: method on a background
 * thread and, once the worker has completed its job, notifies the
 * NMCoreDataWorkerDelegate of the completed job on the main thread.
 */
- (void)performWorkerInBackground:(id<NMCoreDataWorker>)worker
	notifyingDelegateOnMainThread:(id<NMCoreDataWorkerDelegate>)delegate;



#pragma mark Utilities

/**
 * Returns the NSEntityDescription for the entity with the given name defined in
 * the main thread's NSManagedObjectContext.
 */
- (NSEntityDescription *)entityDescriptionForName:(NSString *)name;

- (NSFetchRequest *)fetchRequestForTemplate:(NSString *)templateName withVariables:(NSDictionary *)variables;

@end


#pragma mark -
#pragma mark Core Data Worker

/**
 * Protocol of a background thread worker that wants to perform some work with a
 * NSManagedObjectContext.
 */
@protocol NMCoreDataWorker

/**
 * Called on a background thread with a valid NSManagedObjectContext on which
 * the NMCoreDataWorker can now perform its job.
 *
 * Any saves done to the NSManagedObjectContext will be broadcasted to the main
 * thread's and any other open context.
 *
 * \param manager The NMCoreDataStack in which the worker executes.
 * \param context The NSManagedObjectContext in which the worker can safely
 *				  perform its work.
 */
- (void)performWorkWithManager:(NMCoreDataStack *)stack context:(NSManagedObjectContext *)context;

@end


#pragma mark -
#pragma mark Fetch Delegate

/**
 * Delegate protocol for listening for the results of a background fetch.
 */
@protocol NMCoreDataFetchDelegate

/**
 * Called upon a completed fetch request.
 *
 * \param request The request which did complete.
 * \param result The NSManagedObjects which were returned by the fetch. The
 *				 objects can savely be used on the thread that this method has
 *				 been invoked on.
 */
- (void)fetchRequest:(NSFetchRequest *)request didFetchObjects:(NSArray *)result;

/**
 * Called upon a failed fetch request.
 *
 * \param request The request which failed.
 * \param error The error which caused the request to fail.
 */
- (void)fetchRequest:(NSFetchRequest *)request didFailWithError:(NSError *)error;

@end


#pragma mark -
#pragma mark Worker Delegate

/**
 * Delegate protocol for listening for completion of a NMCoreDataWorker's work.
 */
@protocol NMCoreDataWorkerDelegate

/**
 * Called once the worker did complete.
 *
 * \param worker The NMCoreDataWorker which completed its job.
 */
- (void)workerDidFinish:(id<NMCoreDataWorker>)worker;

@end



