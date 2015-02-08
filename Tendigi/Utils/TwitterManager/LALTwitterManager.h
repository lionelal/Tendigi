//
//  LALTwitterManager.h
//  Tendigi
//
//  Created by Lionel on 06/02/2015.
//  Copyright (c) 2015 Lionel. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Social;
#import <Accounts/Accounts.h>

@interface LALTwitterManager : NSObject

typedef NS_ENUM(NSInteger, TwitterErrorType) {
    TwitterErrorTypeNone,
    TwitterErrorTypeNoNetwork,
    TwitterErrorTypeUnknown
};

+(LALTwitterManager *)sharedManager;

- (void)getTwitterUserWithCompletionBlock:(void(^)(NSDictionary *jsonResponse, TwitterErrorType error))completionBlock;
- (void)getTwitterFeedsWithMaxId:(NSNumber *)maxId completionBlock:(void (^)(NSArray* jsonResponse, TwitterErrorType error))completionBlock;

@end
