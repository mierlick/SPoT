//
//  StranfordTagsTableViewController.m
//  SPoT
//
//  Created by Matthew I Erlick on 4/2/13.
//  Copyright (c) 2013 Matthew I Erlick. All rights reserved.
//

#import "StanfordTagsTableViewController.h"
#import "FlickrFetcher.h"
#import "SPoTNetworkActivity.h"

@interface StanfordTagsTableViewController ()

@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSDictionary *photosByTag;
@property (nonatomic, strong) NSArray *ignoredTags;

@end


@implementation StanfordTagsTableViewController

@synthesize tags = _tags;

- (NSDictionary *)photosByTag
{
    if (!_photosByTag) {
        _photosByTag  = [[NSDictionary alloc] init];
    }
    return _photosByTag;
}

- (NSArray *)tags{
    if(!_tags) {
        _tags = [[NSArray alloc] init];
    }
    return _tags;
}

-(void)setTags:(NSArray *)tags{
	if (_tags!=tags){ // only set and reload if tags have changed
		_tags=tags;
		[self.tableView reloadData];
	}
}

- (NSArray *)ignoredTags
{
    return [[NSArray alloc] initWithObjects:@"cs193pspot", @"portrait", @"landscape", nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refresh];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    
    dispatch_queue_t tagLoadingQueue = dispatch_queue_create("tagLoadingQueue", NULL);
    dispatch_async(tagLoadingQueue, ^{
        [SPoTNetworkActivity startNetworkActivity];
        NSDictionary *updatedPhotosByTags = [self arrangePhotosByTag:[FlickrFetcher stanfordPhotos]];
        [SPoTNetworkActivity stopNetworkActivity];
        NSArray *updatedTags = [[updatedPhotosByTags allKeys] sortedArrayUsingSelector:@selector(compare:)];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photosByTag = updatedPhotosByTags;
            self.tags = updatedTags;
            [self.refreshControl endRefreshing];
        });
    });
}

-(NSDictionary *)arrangePhotosByTag:(NSArray *)photos
{
    NSMutableDictionary *photosByTag = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *photo in photos) {
        
        //Gather Tags and Remove Ignored Tags
        NSMutableArray *tags = [[photo[FLICKR_TAGS] componentsSeparatedByString:@" "] mutableCopy];
        [tags removeObjectsInArray:self.ignoredTags];
        
        //Add Photo To the Tags
        for (NSString *tag in tags) {

            //Make sure tag exists if not add it
            if (![photosByTag objectForKey:tag]) {
                [photosByTag setObject:[[NSMutableArray alloc] init] forKey:tag];
            }
            
            //Add photo to tag and sort
            [(NSMutableArray *)[photosByTag objectForKey:tag] addObject:photo];
            [(NSMutableArray *)[photosByTag objectForKey:tag] sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES], nil]];
        }
    }
    return photosByTag;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.tags count];
}

-(NSString *)titleForRow:(NSUInteger)row
{
    return [self.tags[row] capitalizedString];
}

-(NSString *)subTitleForRow:(NSUInteger)row
{
    int count =[(NSMutableArray *)[self.photosByTag objectForKey:self.tags[row]] count];
    return [NSString stringWithFormat:@"%d photo%@",count,(count == 1) ? @"" : @"s"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"Tag";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subTitleForRow:indexPath.row];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Photo List"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setPhotos:)]) {
                    NSArray *photos = [NSArray arrayWithArray:(NSMutableArray *)[self.photosByTag objectForKey:self.tags[indexPath.row]]];
                    [segue.destinationViewController performSelector:@selector(setPhotos:) withObject:photos];
                    [segue.destinationViewController setTitle:[self titleForRow:indexPath.row]];
                }
            }
        }
    }
}

@end
