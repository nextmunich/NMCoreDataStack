//
//  NMCoreDataStackAppDelegate.m
//  NMCoreDataStack
//
//  Created by Benjamin Broll on 15.04.11.
//  Copyright NEXT Munich. The App Agency. 2011. All rights reserved.
//

#import "NMCoreDataStackAppDelegate.h"


@implementation NMCoreDataStackAppDelegate

#pragma mark Properties

@synthesize window;
@synthesize workersController;
@synthesize fetchesController;


#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

    // Override point for customization after application launch.
	
	//[window addSubview:workersController.view];
	[window addSubview:fetchesController.view];
	
    [window makeKeyAndVisible];
	
	return YES;
}


- (void)dealloc {
    [window release];
	[workersController release];
	[fetchesController release];
	
    [super dealloc];
}


@end
