//
//  LALFeedsViewController.m
//  Tendigi
//
//  Created by Lionel on 06/02/2015.
//  Copyright (c) 2015 Lionel. All rights reserved.
//

#import "LALFeedsViewController.h"

#import "LALDataManager.h"
#import "Models.h"
#import "UIImageView+AFNetworking.h"
#import "NSDate+utils.h"
#import "LALFeedCollectionViewCell.h"

@interface LALFeedsViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray *feeds;
@property (nonatomic, strong) LALTwitterUser *user;
@property (nonatomic, weak) UIRefreshControl *refreshControl;

@property (nonatomic) BOOL loadingMore;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *followingLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bannerImageView;

@end

@implementation LALFeedsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupCollectionView];
    [_refreshControl beginRefreshing];
    [self reloadAllData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Reload data

- (void)reloadAllData {
    [self reloadUserAndFeeds];
}

- (void)reloadFeeds {
    [[LALDataManager sharedManager] allFeedsWithCompletionBlock:^(NSArray *feeds, TwitterErrorType error) {
        [_refreshControl endRefreshing];
        if (error == TwitterErrorTypeNone) {
            _feeds = [feeds mutableCopy];
            [self.collectionView reloadData];
        }
    }];
}

- (void) loadMoreFeeds {
    [[LALDataManager sharedManager] moreFeedsWithCompletionBlock:^(NSArray *feeds, TwitterErrorType error) {
        [_refreshControl endRefreshing];
        _loadingMore = NO;
        [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.feeds.count inSection:0]]];
        if (error == TwitterErrorTypeNone) {
            NSUInteger feedsOldCount = [_feeds count];
            [_feeds addObjectsFromArray:feeds];
            NSUInteger feedsNewCount = [_feeds count];
            
            // Insert new feeds instead of reloadData
            NSMutableArray *indexPaths = [NSMutableArray new];
            for (NSUInteger i = feedsOldCount; i < feedsNewCount; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            [self.collectionView insertItemsAtIndexPaths:indexPaths];
            
        }
    }];
}

- (void)reloadUserAndFeeds {
    [[LALDataManager sharedManager] userWithCompletionBlock:^(LALTwitterUser *user, TwitterErrorType error) {
        if (error == TwitterErrorTypeNone) {
            _user = user;
            _followersLabel.text = [NSString stringWithFormat:@"%lu Followers", (unsigned long)_user.followersCount];
            _followingLabel.text = [NSString stringWithFormat:@"%lu Following", (unsigned long)_user.followingCount];
            _tweetsLabel.text = [NSString stringWithFormat:@"%lu Tweets", (unsigned long)_user.tweetsCount];
            [_userImageView setImageWithURL:[NSURL URLWithString:user.largeImageURL] placeholderImage:nil];
            [_bannerImageView setImageWithURL:[NSURL URLWithString:user.bannerImageURL] placeholderImage:nil];
            
            [self reloadFeeds];
        }
        else {
            [_refreshControl endRefreshing];
        }
    }];
}

#pragma mark - UICollectionView

- (void) setupCollectionView {
    // UICollectionLayout
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        layout.columnCount = 3;
    }
    else {
        layout.columnCount = 2;
    }
    layout.sectionInset = ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).sectionInset;
    self.collectionView.collectionViewLayout = layout;
    
    // Refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(reloadAllData)
             forControlEvents:UIControlEventValueChanged];
    _refreshControl = refreshControl;
    [self.collectionView addSubview:refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
}

#pragma mark - UICollectionViewDatasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _loadingMore ? [self.feeds count] + 1 : [self.feeds count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LALFeedCollectionViewCell *cell = nil;
    
    // Load More
    if (indexPath.row == self.feeds.count) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LoadingCell" forIndexPath:indexPath];
        return cell;
    }
    if (_loadingMore == NO && indexPath.row == self.feeds.count - 1) {
        _loadingMore = YES;
        [collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]]];
        [self loadMoreFeeds];
    }
    
    // Feed Cell
    LALTwitterFeed *feed = [_feeds objectAtIndex:indexPath.row];
    
    if (feed.imageURL) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageFeedCell" forIndexPath:indexPath];
    }
    else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SimpleFeedCell" forIndexPath:indexPath];
    }
    
    cell.usernameLabel.text = feed.user.name;
    cell.feedLabel.text = feed.text;
    cell.dateLabel.text = [feed.date stringValue];
    [cell.userImageView setImageWithURL:[NSURL URLWithString:feed.user.imageURL] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cell.feedImageView.image = nil;
    [cell.feedImageView setImageWithURL:[NSURL URLWithString:feed.imageURL] placeholderImage:nil];

    // border user image
    [cell.userImageView.layer setBorderWidth:2.0];
    [cell.userImageView.layer setBorderColor:[UIColor grayColor].CGColor];
    
    [self appearingAnimationForCell:cell];
    
    return cell;
}

#pragma mark - Animations

- (void)appearingAnimationForCell:(LALFeedCollectionViewCell *)cell {
    CGRect finalCellFrame = cell.frame;
    //check the scrolling direction to verify from which side of the screen the cell should come.
    CGPoint translation = [self.collectionView.panGestureRecognizer translationInView:self.collectionView.superview];
    if (translation.x > 0) {
        cell.frame = CGRectMake(finalCellFrame.origin.x - 10,
                                finalCellFrame.origin.y + 10.0f,
                                finalCellFrame.size.width,
                                finalCellFrame.size.height);
    } else {
        cell.frame = CGRectMake(finalCellFrame.origin.x + 10,
                                finalCellFrame.origin.y - 10.0f,
                                finalCellFrame.size.width,
                                finalCellFrame.size.height);
    }
    cell.alpha = 0.0;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.8f];
    cell.frame = finalCellFrame;
    cell.alpha = 1.0;
    [UIView commitAnimations];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Loading Cell
    if (indexPath.row == self.feeds.count) {
        return CGSizeMake(157, 100);
    }
    
    // Calculate the cell height
    LALTwitterFeed *feed = [_feeds objectAtIndex:indexPath.row];
    CGFloat preferredCellHeight = feed.imageURL == nil ? 163.0 : 320.0;
    CGFloat preferredLabelHeight = 85.0;
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    
    CGFloat cellWidth = [((CHTCollectionViewWaterfallLayout *)collectionView.collectionViewLayout) itemWidthInSectionAtIndex:indexPath.section];
    CGSize maxSize = CGSizeMake(cellWidth - 16.0, MAXFLOAT);
    CGRect labelRect = [feed.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    CGFloat heightDiff = labelRect.size.height - preferredLabelHeight;

    return CGSizeMake(cellWidth, preferredCellHeight + ceilf(heightDiff));
}

@end
