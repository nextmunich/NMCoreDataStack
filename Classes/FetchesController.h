//
//  FetchesController.h
//  NMCoreDataStack
//
//  Created by Benjamin Broll on 25.04.11.
//  Copyright 2011 NEXT Munich. The App Agency. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NMCoreDataStack.h"


@interface FetchesController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, NMCoreDataFetchDelegate> {
	
	// Model
	NMCoreDataStack *stack;
	
	NSArray *results;
	
}

@end
