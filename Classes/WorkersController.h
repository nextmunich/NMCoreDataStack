//
//  WorkersController.h
//  NMCoreDataStack
//
//  Created by Benjamin Broll on 15.04.11.
//  Copyright 2011 NEXT Munich. The App Agency. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NMCoreDataStack.h"


@interface WorkersController : UIViewController <NMCoreDataWorkerDelegate> {

	// View
	UILabel *workerCountLabel;
	
	// Model
	NMCoreDataStack *stack;
	
	NSInteger numberOfWorkers;
	
}

@property (nonatomic, retain) IBOutlet UILabel *workerCountLabel;

- (IBAction)scheduleWork;

@end
