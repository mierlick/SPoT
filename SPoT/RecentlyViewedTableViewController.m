//
//  RecentlyViewedTableViewController.m
//  SPoT
//
//  Created by Matthew I Erlick on 4/2/13.
//  Copyright (c) 2013 Matthew I Erlick. All rights reserved.
//

#import "RecentlyViewedTableViewController.h"
#import "RecentlyViewed.h"

@implementation RecentlyViewedTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refresh];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    
    dispatch_queue_t tableLoadingView = dispatch_queue_create("tableLoadingView", NULL);
    dispatch_async(tableLoadingView, ^{
        NSArray *updatedRecentPhotos = [RecentlyViewed retrieveRecentlyViewed];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = updatedRecentPhotos;
            [self.refreshControl endRefreshing];
        });
    });
}

@end
