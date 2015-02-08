//
//  LALTwitterFeed.m
//  Tendigi
//
//  Created by Lionel on 06/02/2015.
//  Copyright (c) 2015 Lionel. All rights reserved.
//

#import "LALTwitterFeed.h"

#import "LALTwitterUser.h"
#import "NSString+utils.h"

@implementation LALTwitterFeed

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.feedId = dictionary[@"id"];
        self.text = dictionary[@"text"];
        NSArray *medias = dictionary[@"entities"][@"media"];
        if ([medias count]) {
            self.imageURL = [medias firstObject][@"media_url"];
        }
        NSString *dateStr = dictionary[@"created_at"];
        NSDate *date = [dateStr twitterDate];
        self.date = date;
        self.user = [[LALTwitterUser alloc] initWithDictionary:dictionary[@"user"]];
    }
    
    return self;
}

@end
