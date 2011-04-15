//
//  NMCoreDataUtilities.h
//  NMCoreDataStack
//
//  Created by Benjamin Broll on 27.01.11.
//  Copyright 2011 NEXT Munich. The App Agency. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>


@interface NMCoreDataUtilities : NSObject {

}


#pragma mark Managed Objects

+ (NSArray *)objectIDsForObjects:(NSArray *)objects;
+ (NSArray *)objectsForObjectIDs:(NSArray *)objectIDs inContext:(NSManagedObjectContext *)context;


@end
