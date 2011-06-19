//
//  NSManagedObject+NMInstantiation.h
//  NMCoreDataStack
//
//  Created by Benjamin Broll on 05.05.11.
//  Copyright 2011 NEXT Munich. The App Agency. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface NSManagedObject (NMInstantiation)

+ (id)newObjectInContext:(NSManagedObjectContext *)ctx;

@end
