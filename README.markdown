# Introduction

Core Data is a great framework for data-centric apps but comes with its complexities. Especially
when trying to build multithreaded apps (think of an app which performs a search on data stored with
Core Data on a background thread), Core Data's thread confinement rules and their implications
can lead to bugs that are hard to track down.

Based on our experience with several projects that make heavy use of Core Data for maintaining a
local copy of a database stored on a server (including the synchronization of the server's data with
its local copy) and allow searching the database asynchroneously, we've come up with NMCoreDataStack
for simplifying these use-cases and are now releasing its source under the BSD license.


# How to get started

Have a look at the samples provided with the Xcode project. The samples showcase the two fundamental
types of operation with NMCoreDataStack: Workers and Fetches.

## Workers

An NMCoreDataWorker is an object which performs some work on an NSManagedObjectContext. This can be
anything from adding and removing objects to changing their values and saving the context.

NMCoreDataStack allows the execution of NMCoreDataWorker objects on a background thread, taking care
of saves to the NSManagedObjectContext and properly propagating the saves to any other
NSManagedObjectContext.

Once an NMCoreDataWorker is done, an optional delegate is notified of the worker's completion on the
main thread.

## Fetches

Even though a fetch is only a special type of worker that an NMCoreDataWorker can perform, we've
added special support for fetching: NMCoreDataStack can execute an NSFetchRequest on a background
thread, notifying a delegate object of its completion on the main thread. When the delegate object
is notified, it is passed the results of the NSFetchRequest loaded on the main thread so that the
objects can be used to update your user interface.

Any currently running or pending fetch can be cancelled which guarantees that the fetch's delegate
will not be notified. This greatly simplifies the implementation of search interfaces where a search
can be cancelled via the UI.


# Future

There are a couple of things we have in mind to improve upon the current version of NMCoreDataStack.
For example, we're looking to implement convenience methods for executing blocks as workers so that
you do not have to explicitly create NMCoreDataWorker subclasses to perform Core Data work.


