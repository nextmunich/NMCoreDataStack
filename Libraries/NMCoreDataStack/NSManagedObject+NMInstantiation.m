//
//  NSManagedObject+NMInstantiation.m
//  NMCoreDataStack
//
//  Created by Benjamin Broll on 05.05.11.
//  Copyright 2011 NEXT Munich. The App Agency. All rights reserved.
//

#import "NSManagedObject+NMInstantiation.h"


@implementation NSManagedObject (NMInstantiation)

+ (id)newObjectInContext:(NSManagedObjectContext *)ctx {
	NSString *name = NSStringFromClass(self);
	return [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:ctx];
}

@end
