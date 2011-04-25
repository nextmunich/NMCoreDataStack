//
//  Worker.h
//  NMCoreDataStack
//
//  Created by Benjamin Broll on 26.04.11.
//  Copyright 2011 NEXT Munich. The App Agency. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NMCoreDataStack.h"


@interface Worker : NSObject <NMCoreDataWorker> {
	
	NSInteger startIndex, endIndex;
	
}

@property (nonatomic, assign) NSInteger startIndex;
@property (nonatomic, assign) NSInteger endIndex;

@end
