//
//  Cache.m
//  SpoT
//
//  Created by Aleksander Grzyb on 7/23/13.
//  Copyright (c) 2013 Aleksander Grzyb. All rights reserved.
//

#import "Cache.h"

#define IPHONE_STORAGE 3072000 // 3 MB
#define IPAD_STORAGE 9216000 // 9 MB
#define BUNDLE_INFO @"com.aleksandergrzyb.SpoT"

@interface Cache ()
@property (strong, nonatomic) NSFileManager *fileManager;
@end

@implementation Cache


- (NSFileManager *)fileManager
{
    if (!_fileManager) {
        _fileManager = [[NSFileManager alloc] init];
    }
    return _fileManager;
}

- (NSURL *)urlForFileName:(NSString *)fileName;
{
    NSArray *urls = [self.fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *urlOfFile = [[urls lastObject] URLByAppendingPathComponent:fileName];
    return urlOfFile;
}

- (NSURL *)urlOfCache
{
    return [[self.fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)deleteLastFile
{
    NSArray *contentOfCache = [self.fileManager contentsOfDirectoryAtPath:[[self urlOfCache] path] error:nil];
    NSString *fileToDelete;
    for (NSString *fileName in contentOfCache) {
        if (![fileName isEqualToString:BUNDLE_INFO]) {
            fileToDelete = fileName;
            break;
        }
    }
    [self.fileManager removeItemAtURL:[self urlForFileName:fileToDelete] error:nil];
//    NSLog(@"*** Zdjęcie usunięte: %@ ***", fileToDelete);
}

- (void)listOfFilesInDirectory
{
    NSArray *contentOfCache = [self.fileManager contentsOfDirectoryAtPath:[[self urlOfCache] path] error:nil];
    for (NSString *fileName in contentOfCache) {
        if (![fileName isEqualToString:BUNDLE_INFO]) {
            NSLog(@"%@", fileName);
        }
    }
}

// Yes if there is space for another photo, taking in considaration iPad and iPhone device

- (BOOL)checkCapacityOfCacheDirectory
{
    NSArray *contentOfCache = [self.fileManager contentsOfDirectoryAtPath:[[self urlOfCache] path] error:nil];
    NSUInteger spaceOccupied = 0;
    for (NSString *fileName in contentOfCache) {
        if (![fileName isEqualToString:BUNDLE_INFO]) {
            spaceOccupied += [[NSData dataWithContentsOfURL:[self urlForFileName:fileName]] length];
        }
    }
//    NSLog(@"*** Miejsce zajęte: %d ***", spaceOccupied);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (spaceOccupied >= IPAD_STORAGE) {
            return NO;
        } else {
            return YES;
        }
    } else {
        if (spaceOccupied >= IPHONE_STORAGE) {
            return NO;
        } else {
            return YES;
        }
    }
}

- (NSString *)photoNameFromPhotoURL:(NSURL *)photoURL
{
    return [[[photoURL description] componentsSeparatedByString:@"/"] lastObject];
}

- (UIImage *)photoStoredInCacheWithNetworkPhotoURL:(NSURL *)photoURL
{
    NSString *photoName = [self photoNameFromPhotoURL:photoURL];
    NSArray *contentOfCache = [self.fileManager contentsOfDirectoryAtPath:[[self urlOfCache] path] error:nil];
    BOOL photoFound = NO;
    for (NSString *fileName in contentOfCache) {
        if ([fileName isEqualToString:photoName]) {
            photoFound = YES;
            break;
        }
    }
    if (!photoFound) {
        return nil;
    } else {
        UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[self urlForFileName:photoName]]];
        return image;
    }
}

- (void)addPhotoToCache:(NSData *)photoData withNetworkPhotoURL:(NSURL *)photoURL
{
    NSString *photoName = [self photoNameFromPhotoURL:photoURL];
    BOOL freeSpace = [self checkCapacityOfCacheDirectory];
    if (!freeSpace) {
        [self deleteLastFile];
    }
    [photoData writeToURL:[self urlForFileName:photoName] atomically:NO];
//    [self listOfFilesInDirectory];
//    NSLog(@"*** Zdjęcie dodane: %@ o pojemności: %d ***", photoName, [photoData length]);
}

@end
