//
//  NMCoreDataWorkerOperation.h
//  NMCoreDataStack
//
//  Created by Benjamin Broll on 15.04.11.
//  Copyright 2011 NEXT Munich. The App Agency. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>


@class NMCoreDataStack;

@protocol NMCoreDataWorker;
@protocol NMCoreDataWorkerDelegate;


// this operation is non-concurrent and can thus only be used in operation
// queues

@interface NMCoreDataWorkerOperation : NSOperation {
	
	NMCoreDataStack *stack;
	id<NMCoreDataWorker> worker;
	id<NMCoreDataWorkerDelegate> delegate;
	
}

@property (nonatomic, retain) NMCoreDataStack *stack;
@property (nonatomic, retain) id<NMCoreDataWorker> worker;
@property (nonatomic, assign) id<NMCoreDataWorkerDelegate> delegate;

@end
