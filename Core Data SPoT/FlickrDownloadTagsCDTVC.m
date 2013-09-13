//
//  FlickrDownloadTagsCDTVC.m
//  Core Data SPoT
//
//  Created by Aleksander Grzyb on 7/31/13.
//  Copyright (c) 2013 Aleksander Grzyb. All rights reserved.
//

#import "FlickrDownloadTagsCDTVC.h"
#import "FlickrFetcher.h"
#import "AppDelegate.h"
#import "Photo+Flickr.h"
#import "CoreDataHelper.h"

@implementation FlickrDownloadTagsCDTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.managedObjectContext) {
        [self useDocument];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self action:@selector(loadDataFromFlickr) forControlEvents:UIControlEventValueChanged];
}

- (void)useDocument
{
    UIManagedDocument *document = [CoreDataHelper sharedManagedDocument].sharedDocument;
    NSURL *url = document.fileURL;
    // Checking if the document (database) already exist
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        // Need to be created
        [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
                [self loadDataFromFlickr];
            }
        }];
    } else if (document.documentState == UIDocumentStateClosed) {
        // Need to be opened
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
            }
        }];
    } else {
        // There are other states of document, but we assuming that is open at this point
        self.managedObjectContext = document.managedObjectContext;
    }
}

- (void)loadDataFromFlickr
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t fetchQueue = dispatch_queue_create("Flickr Fetcher", NULL);
    dispatch_async(fetchQueue, ^{
        [(AppDelegate *)[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        NSArray *photos = [FlickrFetcher stanfordPhotos];
        [(AppDelegate *)[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        // We need to execute operations of ManagedObjectContext in thread in which ManagedObjectContext wants to be executed
        [self.managedObjectContext performBlock:^{
            for (NSDictionary *photo in photos) {
                [Photo photoWithFlickrInfo:photo inManagedObjectContext:self.managedObjectContext];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
        }];
    });
}

@end
