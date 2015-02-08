//
//  LALDataManager.h
//  Tendigi
//
//  Created by Lionel on 06/02/2015.
//  Copyright (c) 2015 Lionel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LALTwitterManager.h"
@class LALTwitterUser;

@interface LALDataManager : NSObject

+(LALDataManager *)sharedManager;

- (void)allFeedsWithCompletionBlock:(void(^)(NSArray* feeds, TwitterErrorType error))completionBlock;
- (void)moreFeedsWithCompletionBlock:(void(^)(NSArray* feeds, TwitterErrorType error))completionBlock;
- (void)userWithCompletionBlock:(void(^)(LALTwitterUser *user, TwitterErrorType error))completionBlock;

@end
