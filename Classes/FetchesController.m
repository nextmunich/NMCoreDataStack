//
//  FetchesController.m
//  NMCoreDataStack
//
//  Created by Benjamin Broll on 25.04.11.
//  Copyright 2011 NEXT Munich. The App Agency. All rights reserved.
//

#import "FetchesController.h"

#import "DataItem.h"
#import "Worker.h"


@interface FetchesController (Private)

- (void)postInit;

@end


@implementation FetchesController

#pragma mark Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultCell"];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ResultCell"] autorelease];
	}
	
	DataItem *item = [results objectAtIndex:indexPath.row];
	cell.textLabel.text = item.title;
	cell.detailTextLabel.text = item.content;
	
	return cell;
}


#pragma mark Search Display Controller Delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	
	static NSInteger callCount = 0;
	
	// cancel any pending fetch
	[stack cancelPendingFetches];
	
	// prepare the match regex based on the search string
	NSString *regex = [NSString stringWithFormat:@"(?i:.*%@.*)", searchString];
	
	// we can fetch using a dynamically created fetch request or using a template
	if (callCount % 2 == 0) {
		// prepare fetch request
		NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
		[request setEntity:[stack entityDescriptionForName:@"DataItem"]];
		
		
		[request setPredicate:[NSPredicate predicateWithFormat:@"title MATCHES %@", regex]];
		
		// start fetch
		[stack fetchInBackground:request notifyingDelegateOnMainThread:self];
	} else {
		// start a fetch	
		[stack fetchTemplateInBackground:@"fetchByTitle"
						   withVariables:[NSDictionary dictionaryWithObject:regex forKey:@"TITLE"]
		   notifyingDelegateOnMainThread:self];
	}
	
	callCount++;
	
	// let the search display controller know that we're searching asynchroneously
	return NO;
}


#pragma mark Fetch Delegate

- (void)fetchRequest:(NSFetchRequest *)request didFetchObjects:(NSArray *)r {
	// keep a reference to the search results
	[results release];
	results = [r retain];
	
	// request a reload of the search results table
	[self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)fetchRequest:(NSFetchRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"error in fetch: %@", error);
}


#pragma mark Memory & View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		[self postInit];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		[self postInit];
	}
	
	return self;
}


- (void)postInit {
	// initialize the directory to the database
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:@"dataitems_sample2.db"];
	
	// clean database
	NSError *error;
	NSFileManager *mgr = [NSFileManager defaultManager];
	if ([mgr fileExistsAtPath:databasePath]
		&& ![[NSFileManager defaultManager] removeItemAtPath:databasePath error:&error]) {
		
		NSLog(@"error removing current database. error: %@", error);
	}
	
	// initialize core data stack and allow a maximum of 10 workers to run concurrently
	stack = [[NMCoreDataStack alloc] initWithDatabaseURL:[NSURL fileURLWithPath:databasePath]];
	[stack setMaxConcurrentWorkerCount:10];
	
	// perform a worker which continuously creates new items
	Worker *w = [[[Worker alloc] init] autorelease];
	w.startIndex = 0;
	w.endIndex = 100000;
	[stack performWorkerInBackground:w notifyingDelegateOnMainThread:nil];
}


- (void)dealloc {
	[stack release];
	
	[super dealloc];
}

@end
