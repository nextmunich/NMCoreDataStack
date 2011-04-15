//
//  NMCoreDataFetchOperation.h
//  NMCoreDataStack
//
//  Created by Benjamin Broll on 15.04.11.
//  Copyright 2011 NEXT Munich. The App Agency. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>


@class NMCoreDataStack;

@protocol NMCoreDataFetchDelegate;


// this operation is non-concurrent and can thus only be used in operation
// queues

@interface NMCoreDataFetchOperation : NSOperation {

	NMCoreDataStack *stack;
	NSFetchRequest *request;
	id<NMCoreDataFetchDelegate> delegate;
	
}

@property (nonatomic, retain) NMCoreDataStack *stack;
@property (nonatomic, retain) NSFetchRequest *request;
@property (nonatomic, assign) id<NMCoreDataFetchDelegate> delegate;

@end
