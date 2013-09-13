//
//  Tag+Create.h
//  Core Data SPoT
//
//  Created by Aleksander Grzyb on 7/31/13.
//  Copyright (c) 2013 Aleksander Grzyb. All rights reserved.
//

#import "Tag.h"

@interface Tag (Create)

+ (Tag *)tagWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

@end
