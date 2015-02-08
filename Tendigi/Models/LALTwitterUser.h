//
//  LALTwitterUser.h
//  Tendigi
//
//  Created by Lionel on 06/02/2015.
//  Copyright (c) 2015 Lionel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LALTwitterUser : NSObject

- (id)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *largeImageURL;
@property (nonatomic, strong) NSString *bannerImageURL;
@property (nonatomic) NSUInteger followersCount;
@property (nonatomic) NSUInteger followingCount;
@property (nonatomic) NSUInteger tweetsCount;

@end
