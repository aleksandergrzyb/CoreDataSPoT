//
//  TagsCDTVC.m
//  Core Data SPoT
//
//  Created by Aleksander Grzyb on 7/31/13.
//  Copyright (c) 2013 Aleksander Grzyb. All rights reserved.
//

#import "TagsCDTVC.h"
#import "Tag.h"
#import "CoreDataHelper.h"

@implementation TagsCDTVC

#define ALL_TAGS_STRING @"00000"

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (managedObjectContext) {
        // Request for items that we want to display in this table view
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        // Predicate is nil, because we want to get all tags from database
        request.predicate = nil;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        // Setting fetchedResultsController to nil cause that all tags will be removed from table view
        self.fetchedResultsController = nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Tags Cell"];
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([tag.name isEqualToString:ALL_TAGS_STRING]) {
        cell.textLabel.text = @"All";
    } else {
        cell.textLabel.text = [tag.name capitalizedString];
    }
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos", [tag.photos count]];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"setTag:"]) {
            Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if ([segue.destinationViewController respondsToSelector:@selector(setTag:)]) {
                [segue.destinationViewController performSelector:@selector(setTag:) withObject:tag];
            }
        }
    }
}

@end
