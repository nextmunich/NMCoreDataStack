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


#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

    // Override point for customization after application launch.
	
    [window makeKeyAndVisible];
	
	return YES;
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
