//
//  LALDataManager.m
//  Tendigi
//
//  Created by Lionel on 06/02/2015.
//  Copyright (c) 2015 Lionel. All rights reserved.
//

#import "LALDataManager.h"

#import "Models.h"

@interface LALDataManager ()

@property (nonatomic, strong) NSNumber *maxTweetId;
@end

@implementation LALDataManager

+ (LALDataManager *)sharedManager {
    static LALDataManager *dataManager;
    static dispatch_once_t token;
    dispatch_once (&token, ^{
        dataManager = [[self alloc] init];
    });
    
    return dataManager;
}

- (void)requestFeedsWithCompletionBlock:(void(^)(NSArray* feeds, TwitterErrorType error))completionBlock {
    [[LALTwitterManager sharedManager] getTwitterFeedsWithMaxId:self.maxTweetId completionBlock:^(NSArray *jsonResponse, TwitterErrorType error) {
        if (error == TwitterErrorTypeNone) {
            NSMutableArray *feeds = [NSMutableArray new];
            NSArray *jsonFeeds = jsonResponse;
            for (NSDictionary *feedDict in jsonFeeds) {
                LALTwitterFeed *feed = [[LALTwitterFeed alloc] initWithDictionary:feedDict];
                [feeds addObject:feed];
            }
            
            _maxTweetId = [[feeds lastObject] feedId];
            completionBlock(feeds, error);
        }
        else {
            completionBlock(nil, error);
        }
    }];
}

- (void)allFeedsWithCompletionBlock:(void(^)(NSArray* feeds, TwitterErrorType error))completionBlock {
    self.maxTweetId = nil;
    [self requestFeedsWithCompletionBlock:completionBlock];
}

- (void)moreFeedsWithCompletionBlock:(void(^)(NSArray* feeds, TwitterErrorType error))completionBlock {
    [self requestFeedsWithCompletionBlock:completionBlock];
}

            - (void)userWithCompletionBlock:(void(^)(LALTwitterUser *user, TwitterErrorType error))completionBlock {
                [[LALTwitterManager sharedManager] getTwitterUserWithCompletionBlock:^(NSDictionary *jsonResponse, TwitterErrorType error) {
                    if (error == TwitterErrorTypeNone) {
                        LALTwitterUser *user = [[LALTwitterUser alloc] initWithDictionary:jsonResponse];
                        completionBlock(user, error);
                    }
                    else {
                        completionBlock(nil, error);
                    }
                }];
            }

@end
