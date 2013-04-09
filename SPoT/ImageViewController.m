//
//  ImageViewController.m
//  SPoT
//
//  Created by Matthew I Erlick on 4/2/13.
//  Copyright (c) 2013 Matthew I Erlick. All rights reserved.
//

#import "ImageViewController.h"
#import "SPoTPhotoCache.h"
#import "SPoTNetworkActivity.h"

@interface ImageViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (nonatomic) BOOL stopZooming;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activitySpinner;

@end

@implementation ImageViewController

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    return _imageView;
}

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self resetImage];
}

- (void)resetImage
{
    if (self.scrollView) {
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        self.stopZooming = NO;
        
        NSURL *imageURL = self.imageURL;
        
        [self.activitySpinner startAnimating];
        
        dispatch_queue_t imageFetcherQueue = dispatch_queue_create("imageFetcher", NULL);
        dispatch_async(imageFetcherQueue, ^{
            NSData *imageData = [SPoTPhotoCache imageFromCache:self.imageURL];
            if (!imageData) {
                [SPoTNetworkActivity startNetworkActivity];
                imageData = [[NSData alloc] initWithContentsOfURL:self.imageURL];
                [SPoTNetworkActivity stopNetworkActivity];
                [SPoTPhotoCache cacheImageData:imageData forImageNamed:self.imageURL];
            }
            
            UIImage *image = [[UIImage alloc] initWithData:imageData];

            if (self.imageURL == imageURL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                        self.scrollView.zoomScale = 1.0;
                        self.scrollView.contentSize = image.size;
                        self.imageView.image = image;
                        self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                    }
                    [self.activitySpinner stopAnimating];
                });
            }
        });
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    [self resetImage];
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
    if (self.imageView) {
        [self fillView];
    }
}

- (void)fillView
{
    if (!self.stopZooming) {
        float wScale = self.view.bounds.size.width / self.imageView.bounds.size.width;
        float hScale = self.view.bounds.size.height / self.imageView.bounds.size.height;
        self.scrollView.zoomScale = MAX(wScale, hScale);
    }
}

@end
