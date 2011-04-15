//
//  NMCoreDataStack+Private.h
//  NMCoreDataStack
//
//  Created by Benjamin Broll on 15.04.11.
//  Copyright 2011 NEXT Munich. The App Agency. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>


@interface NMCoreDataStack (Private)

- (NSManagedObjectContext *)borrowNewContext;
- (void)returnContext:(NSManagedObjectContext *)context;

- (void)managedObjectContextDidSave:(NSNotification *)notification;

- (void)createMainThreadContext;

@end
