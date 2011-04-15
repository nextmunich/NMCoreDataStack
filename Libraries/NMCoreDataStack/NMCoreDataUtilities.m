//
//  NMCoreDataUtilities.m
//  NMCoreDataStack
//
//  Created by Benjamin Broll on 27.01.11.
//  Copyright 2011 NEXT Munich. The App Agency. All rights reserved.
//

#import "NMCoreDataUtilities.h"


@implementation NMCoreDataUtilities


#pragma mark Managed Objects

+ (NSArray *)objectIDsForObjects:(NSArray *)objects {
	NSMutableArray *objectIDs = [NSMutableArray arrayWithCapacity:[objects count]];
	
	for (NSManagedObject *object in objects) {
		[objectIDs addObject:object.objectID];
	}
	
	return objectIDs;
}

+ (NSArray *)objectsForObjectIDs:(NSArray *)objectIDs inContext:(NSManagedObjectContext *)context {
	NSMutableArray *results = [NSMutableArray array];
	
	for (NSManagedObjectID* objectID in objectIDs) {
		NSManagedObject* object = [context existingObjectWithID:objectID error:nil];
		if (object != nil) {
			[results addObject:object];
		}
	}
	
	return results;
}


@end
