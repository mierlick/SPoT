//
//  RecentlyViewed.m
//  SPoT
//
//  Created by Matthew I Erlick on 4/2/13.
//  Copyright (c) 2013 Matthew I Erlick. All rights reserved.
//

#import "RecentlyViewed.h"
#import "FlickrFetcher.h"

@implementation RecentlyViewed

#define RECENTLY_VIEW_KEY @"Recently Viewed SPoT Photos"

+ (NSArray *)retrieveRecentlyViewed
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    return [userDefaults arrayForKey:RECENTLY_VIEW_KEY];
}

+ (void)saveRecentlyViewed:(NSDictionary *)photo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *photos = [[userDefaults arrayForKey:RECENTLY_VIEW_KEY] mutableCopy];
    
    if (!photos) {
        photos = [[NSMutableArray alloc] init];
    }
    
    NSString *photoID = [photo valueForKey:FLICKR_PHOTO_ID];
    for (int i = 0 ; i < [photos count]; i ++) {
        NSString *oldPhotoID = [[photos objectAtIndex:i] valueForKey:FLICKR_PHOTO_ID];
        if ([photoID isEqualToString:oldPhotoID]) [photos removeObjectAtIndex:i];

    }
    
    [photos insertObject:photo atIndex:0];
    
    if ([photos count] > RECENTLY_VIEWED_PHOTO_LIMIT) {
        NSRange range;
        range.location = 0;
        range.length = RECENTLY_VIEWED_PHOTO_LIMIT;
        photos = [[photos subarrayWithRange:range] mutableCopy];
    }
    
    [userDefaults setObject:[photos copy] forKey:RECENTLY_VIEW_KEY];
    [userDefaults synchronize];

}

@end
