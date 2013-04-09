//
//  RecentlyViewed.h
//  SPoT
//
//  Created by Matthew I Erlick on 4/2/13.
//  Copyright (c) 2013 Matthew I Erlick. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RECENTLY_VIEWED_PHOTO_LIMIT 25

@interface RecentlyViewed : NSObject

+ (NSArray *)retrieveRecentlyViewed;

+ (void)saveRecentlyViewed:(NSDictionary *)photo;

@end
