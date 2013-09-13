//
//  Cache.h
//  SpoT
//
//  Created by Aleksander Grzyb on 7/23/13.
//  Copyright (c) 2013 Aleksander Grzyb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cache : NSObject

- (UIImage *)photoStoredInCacheWithNetworkPhotoURL:(NSURL *)photoURL;
- (void)addPhotoToCache:(NSData *)photoData withNetworkPhotoURL:(NSURL *)photoURL;

@end
