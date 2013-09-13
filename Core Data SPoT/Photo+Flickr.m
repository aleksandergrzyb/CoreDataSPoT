//
//  Photo+Flickr.m
//  Core Data SPoT
//
//  Created by Aleksander Grzyb on 7/31/13.
//  Copyright (c) 2013 Aleksander Grzyb. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "CoreDataHelper.h"
#import "Tag+Create.h"

@implementation Photo (Flickr)

#define ALL_TAGS_STRING @"00000"

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    // Query database to check if the photo is already in database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"uniqueID = %@", [photoDictionary[FLICKR_PHOTO_ID] description]];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || ([matches count] > 1)) {
         // Error occured (check NSError)
        NSLog(@"Error occured when fetching database for photo.");
    } else if (![matches count]) {
        // Creating new entity for photo
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        // Setting values of photo
        photo.uniqueID = [photoDictionary[FLICKR_PHOTO_ID] description];
        photo.title = [photoDictionary[FLICKR_PHOTO_TITLE] description];
        photo.subtitle = [[photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description];
        photo.imageURL = [[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
        photo.thumbnailURL = [[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
        photo.dateOpened = [NSDate date];
        photo.sectionName = [photo.title substringToIndex:1];
        NSString *tagsOfPhoto = [photoDictionary[FLICKR_TAGS] description];
        NSArray *arrayOfTags = [tagsOfPhoto componentsSeparatedByString:@" "];
        for (NSString *tagName in arrayOfTags) {
            // We don't want tages named "cs193pspot" and "portrait"
            if (![tagName isEqualToString:@"cs193pspot"] && ![tagName isEqualToString:@"portrait"]) {
                // Creating and adding all the tags
                Tag *tag = [Tag tagWithName:tagName inManagedObjectContext:context];
                [photo addTagsObject:tag];
            }
        }
        Tag *tag = [Tag tagWithName:ALL_TAGS_STRING inManagedObjectContext:context];
        [photo addTagsObject:tag];
    } else {
        // Photo found
        photo = [matches lastObject];
    }
    return photo;
}

- (void)deletePhoto
{
    for (Tag *tag in self.tags) {
        if ([tag.photos count] == 1) {
            [[CoreDataHelper sharedManagedDocument].sharedDocument.managedObjectContext deleteObject:tag];
        }
    }
    self.tags = nil;
    
}

@end
