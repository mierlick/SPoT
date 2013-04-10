//
//  SPoTNetworkActivity.m
//  SPoT
//
//  Created by Matthew I Erlick on 4/9/13.
//  Copyright (c) 2013 Matthew I Erlick. All rights reserved.
//

#import "SPoTNetworkActivity.h"

@implementation SPoTNetworkActivity

static NSInteger currentActivitiesAccessingNetworkCount = 0;

+ (void)startNetworkActivity
{
    [self updateLoadCountWithCount:1];
}

+ (void)stopNetworkActivity
{
    [self updateLoadCountWithCount:-1];
}

+ (void)updateLoadCountWithCount:(NSInteger)count
{
    @synchronized(self)
    {
        currentActivitiesAccessingNetworkCount += count ;
        currentActivitiesAccessingNetworkCount = (currentActivitiesAccessingNetworkCount < 0) ? 0 : currentActivitiesAccessingNetworkCount;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = (currentActivitiesAccessingNetworkCount > 0);
    }
}

@end
