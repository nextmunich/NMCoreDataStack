//
//  NMCoreDataStackAppDelegate.h
//  NMCoreDataStack
//
//  Created by Benjamin Broll on 15.04.11.
//  Copyright NEXT Munich. The App Agency. 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NMCoreDataStackAppDelegate : NSObject <UIApplicationDelegate> {

    UIWindow *window;
	
	UIViewController *workersController;
	UIViewController *fetchesController;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UIViewController *workersController;
@property (nonatomic, retain) IBOutlet UIViewController *fetchesController;

@end

