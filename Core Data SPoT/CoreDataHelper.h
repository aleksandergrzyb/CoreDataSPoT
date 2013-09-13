//
//  CoreDataHelper.h
//  Core Data SPoT
//
//  Created by Aleksander Grzyb on 8/1/13.
//  Copyright (c) 2013 Aleksander Grzyb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataHelper : NSObject

@property (readonly, strong, nonatomic) UIManagedDocument *sharedDocument;

+ (CoreDataHelper *)sharedManagedDocument;

@end
