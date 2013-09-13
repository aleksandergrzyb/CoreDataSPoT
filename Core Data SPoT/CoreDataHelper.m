//
//  CoreDataHelper.m
//  Core Data SPoT
//
//  Created by Aleksander Grzyb on 8/1/13.
//  Copyright (c) 2013 Aleksander Grzyb. All rights reserved.
//

#import "CoreDataHelper.h"

@interface CoreDataHelper()

@property (readwrite, strong, nonatomic) UIManagedDocument *sharedDocument;

@end

@implementation CoreDataHelper

+ (CoreDataHelper *)sharedManagedDocument
{
    static dispatch_once_t once;
    static id _sharedInstance;
    dispatch_once(&once, ^{
        _sharedInstance = [[CoreDataHelper alloc] init];
    });
    return _sharedInstance;
}

- (UIManagedDocument *)sharedDocument
{
    // lazy instantiation
    if (!_sharedDocument) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Flickr Document"];
        _sharedDocument = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    return _sharedDocument;
}

@end
