//
//  Tag+Create.m
//  Core Data SPoT
//
//  Created by Aleksander Grzyb on 7/31/13.
//  Copyright (c) 2013 Aleksander Grzyb. All rights reserved.
//

#import "Tag+Create.h"

@implementation Tag (Create)

+ (Tag *)tagWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    Tag *tag = nil;
    if (name.length) {
        // Checking if tag is already in database
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        NSError *error = nil;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        if (!matches || ([matches count] > 1)) {
             // Error occured (check NSError)
            NSLog(@"Error occured when checking database for tag named: %@.", name);
        } else if (![matches count]) {
            // Adding new entity
            tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
            tag.name = name;
        } else {
            // Tag found
            tag = [matches lastObject];
        }
    }
    return tag;
}

@end
