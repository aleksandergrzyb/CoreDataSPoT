//
//  ImageViewController.m
//  Core Data SPoT
//
//  Created by Aleksander Grzyb on 8/1/13.
//  Copyright (c) 2013 Aleksander Grzyb. All rights reserved.
//

#import "ImageViewController.h"
#import "AppDelegate.h"
#import "Cache.h"

@interface ImageViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleBarButtonItem;
@property (strong, nonatomic) Cache *cache;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ImageViewController

- (void)setTitle:(NSString *)title
{
    super.title = title;
    self.titleBarButtonItem.title = title;
}

- (void)setPhotoURL:(NSURL *)photoURL
{
    _photoURL = photoURL;
    [self resetImage];
}

- (Cache *)cache
{
    if (!_cache) {
        _cache = [[Cache alloc] init];
        
    }
    return _cache;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    self.titleBarButtonItem.title = self.title;
    [self resetImage];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)viewDidLayoutSubviews
{
    CGFloat zoomScale = 0.0;
    CGFloat horizontalZoomRatio = 0.0;
    CGFloat verticalZoomRatio = 0.0;
    verticalZoomRatio = self.scrollView.bounds.size.height / self.imageView.image.size.height;
    horizontalZoomRatio = self.scrollView.bounds.size.width / self.imageView.image.size.width;
    if (verticalZoomRatio > 1 && horizontalZoomRatio < 1) {
        zoomScale = self.imageView.image.size.height / self.scrollView.bounds.size.height;
    } else if (verticalZoomRatio < 1 && horizontalZoomRatio > 1) {
        zoomScale = self.imageView.image.size.width / self.scrollView.bounds.size.width;
    } else if ((verticalZoomRatio > 1 && horizontalZoomRatio > 1) || (verticalZoomRatio < 1 && horizontalZoomRatio < 1)) {
        if (verticalZoomRatio > horizontalZoomRatio) {
            zoomScale = verticalZoomRatio;
        } else {
            zoomScale = horizontalZoomRatio;
        }
    }
    [self.scrollView setZoomScale:zoomScale animated:NO];
}

- (void)resetImage
{
    if (self.scrollView && self.title && self.photoURL) {
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        NSURL *photoURL = self.photoURL;
        UIImage *imageFromCache = [self.cache photoStoredInCacheWithNetworkPhotoURL:self.photoURL];
        if (!imageFromCache) {
            [self.activityIndicator startAnimating];
            dispatch_queue_t photoDownload = dispatch_queue_create("Specyfic Photo Downloar", NULL);
            dispatch_async(photoDownload, ^{
                [(AppDelegate *)[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                NSData *imageData = [[NSData alloc] initWithContentsOfURL:self.photoURL];
                [(AppDelegate *)[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                if (self.photoURL == photoURL) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.cache addPhotoToCache:imageData withNetworkPhotoURL:self.photoURL];
                        if (image) {
                            self.scrollView.zoomScale = 1.0;
                            self.scrollView.contentSize = image.size;
                            self.imageView.image = image;
                            self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                        }
                        [self.activityIndicator stopAnimating];
                        [self viewDidLayoutSubviews];
                    });
                }
            });
        } else {
            self.scrollView.zoomScale = 1.0;
            self.scrollView.contentSize = imageFromCache.size;
            self.imageView.image = imageFromCache;
            self.imageView.frame = CGRectMake(0, 0, imageFromCache.size.width, imageFromCache.size.height);
        }
    }
}

@end
