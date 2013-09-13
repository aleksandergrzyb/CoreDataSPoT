//
//  HistoryCDTVC.m
//  Core Data SPoT
//
//  Created by Aleksander Grzyb on 8/1/13.
//  Copyright (c) 2013 Aleksander Grzyb. All rights reserved.
//

#import "HistoryCDTVC.h"
#import "Photo.h" 
#import "CoreDataHelper.h"
#import "ImageViewController.h"

@implementation HistoryCDTVC

#define RECENT_PHOTO_LIMIT 25.0

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.managedObjectContext) {
        self.managedObjectContext = [CoreDataHelper sharedManagedDocument].sharedDocument.managedObjectContext;
    }
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    [self setupFetchedResultsController];
}

- (void)setupFetchedResultsController
{
    if (self.managedObjectContext) {
        NSLog(@"Fetching");
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateOpened" ascending:NO]];
        request.predicate = nil;
        request.fetchLimit = RECENT_PHOTO_LIMIT;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.managedObjectContext = nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"History Cell"];
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    if (photo.thumbnail) {
        cell.imageView.image = [UIImage imageWithData:photo.thumbnail];
    }
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"setPhotoURL:"]) {
            Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if ([segue.destinationViewController respondsToSelector:@selector(setPhotoURL:)]) {
                ImageViewController *imageViewController = (ImageViewController *)segue.destinationViewController;
                NSLog(@"Ustawiam datę");
                photo.dateOpened = [NSDate date];
                imageViewController.photoURL = [NSURL URLWithString:photo.imageURL];
                imageViewController.title = photo.title;
            }
        }
    }
}

@end
