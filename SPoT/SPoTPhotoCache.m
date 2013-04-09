//
//  SPoTPhotoCache.m
//  SPoT
//
//  Created by Matthew I Erlick on 4/8/13.
//  Copyright (c) 2013 Matthew I Erlick. All rights reserved.
//

#import "SPoTPhotoCache.h"

@implementation SPoTPhotoCache

#define MAX_PHOTOS_STORED 10

+ (NSData *)imageFromCache:(NSURL *)imageURL
{
    if (imageURL) {
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSArray *documentDirectory = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        NSURL *cachedURL = [[documentDirectory lastObject] URLByAppendingPathComponent:[[imageURL pathComponents] lastObject]];
        if ([cachedURL isFileURL]) {
            if ([fileManager fileExistsAtPath:[cachedURL path]]) {
                return [NSData dataWithContentsOfURL:cachedURL];
            }
        }
    }
    return nil;
}

+ (void)cacheImageData:(NSData *)imageData forImageNamed:(NSURL *)imageURL
{
    if (imageURL) {
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSArray *documentDirectory = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        
        NSURL *destinationURL = [[documentDirectory lastObject] URLByAppendingPathComponent:[[imageURL pathComponents] lastObject]];
        
        NSArray *documentDirectoryContents = [fileManager contentsOfDirectoryAtURL:[documentDirectory lastObject] includingPropertiesForKeys:NULL options:NSDirectoryEnumerationSkipsHiddenFiles error:NULL];
        
        if ([destinationURL isFileURL]) {
            if (![fileManager fileExistsAtPath:[destinationURL path]]) {
                [imageData writeToFile:[destinationURL path] atomically:YES];
                
                if ([documentDirectoryContents count] >= MAX_PHOTOS_STORED) {
                    NSURL *fileToRemove = [documentDirectoryContents lastObject];
                    NSDate *oldestDate = [[fileManager attributesOfItemAtPath:[fileToRemove path] error:NULL] fileModificationDate];
                    
                    for (NSURL *storedDocument in documentDirectoryContents) {
                        NSDictionary *attributes = [fileManager attributesOfItemAtPath:[storedDocument path] error:NULL];
                        NSDate *currentDocumentDate = [attributes fileModificationDate];
                        oldestDate = [oldestDate earlierDate:currentDocumentDate];
                        fileToRemove = storedDocument;
                    }
                    
                    [fileManager removeItemAtURL:fileToRemove error:NULL];
                }
            }
        }
    }
}

@end
