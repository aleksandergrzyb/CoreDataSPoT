//
//  PhotosByTagCDTVC.m
//  Core Data SPoT
//
//  Created by Aleksander Grzyb on 8/1/13.
//  Copyright (c) 2013 Aleksander Grzyb. All rights reserved.
//

#import "PhotosByTagCDTVC.h"
#import "ImageViewController.h"
#import "Photo.h"
#import "Photo+Flickr.h"
#import "CoreDataHelper.h"
#import "AppDelegate.h"

@interface PhotosByTagCDTVC ()
@property (nonatomic) BOOL thumbnailDataDownloaded;
@end

@implementation PhotosByTagCDTVC

#define ALL_TAGS_STRING @"00000"

- (void)setTag:(Tag *)tag
{
    _tag = tag;
    if ([tag.name isEqualToString:ALL_TAGS_STRING]) {
        self.title = @"All";
    } else {
        self.title = [tag.name capitalizedString];
    }
    [self setupFetchedResultsController];
}

- (void)setupFetchedResultsController
{
    if (self.tag.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sectionName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"ANY tags = %@", self.tag];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:[CoreDataHelper sharedManagedDocument].sharedDocument.managedObjectContext
                                                                              sectionNameKeyPath:@"sectionName"
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photos Cell"];
    
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    cell.imageView.image = [UIImage imageWithData:photo.thumbnail];
    if (!cell.imageView.image) {
        dispatch_queue_t fetchQueue = dispatch_queue_create("Flickr Thumbnail", NULL);
        dispatch_async(fetchQueue, ^{
            [(AppDelegate *)[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:photo.thumbnailURL]];
            [(AppDelegate *)[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [photo.managedObjectContext performBlock:^{
                photo.thumbnail = data;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setNeedsDisplay];
                });
            }];
        });
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        __block Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[CoreDataHelper sharedManagedDocument].sharedDocument.managedObjectContext performBlock:^{
            [photo deletePhoto];
        }];
    }
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
                photo.dateOpened = [NSDate date];
                imageViewController.photoURL = [NSURL URLWithString:photo.imageURL];
                imageViewController.title = photo.title;
            }
        }
    }
}

@end















