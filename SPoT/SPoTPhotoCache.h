//
//  SPoTPhotoCache.h
//  SPoT
//
//  Created by Matthew I Erlick on 4/8/13.
//  Copyright (c) 2013 Matthew I Erlick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPoTPhotoCache : NSObject <NSFileManagerDelegate>

+ (void)cacheImageData:(NSData *)imageData forImageNamed:(NSURL *)imageURL;
+ (NSData *)imageFromCache:(NSURL *)imageURL;

@end
