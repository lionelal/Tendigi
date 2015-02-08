//
//  LALTwitterFeed.h
//  Tendigi
//
//  Created by Lionel on 06/02/2015.
//  Copyright (c) 2015 Lionel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LALTwitterUser;

@interface LALTwitterFeed : NSObject

- (id)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, strong) NSNumber *feedId;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSDate *date;

@property (nonatomic, strong) LALTwitterUser *user;

@end
