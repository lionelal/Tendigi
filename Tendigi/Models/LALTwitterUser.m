//
//  LALTwitterUser.m
//  Tendigi
//
//  Created by Lionel on 06/02/2015.
//  Copyright (c) 2015 Lionel. All rights reserved.
//

#import "LALTwitterUser.h"

@implementation LALTwitterUser

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _name = [dictionary objectForKey:@"name"];
        _imageURL = [dictionary objectForKey:@"profile_image_url"];
        
        self.followersCount = [[dictionary objectForKey:@"followers_count"] unsignedIntegerValue];
        self.followingCount = [[dictionary objectForKey:@"friends_count"] unsignedIntegerValue];
        self.tweetsCount = [[dictionary objectForKey:@"statuses_count"] unsignedIntegerValue];
        
        //Get larger Twitter Profile image
        self.imageURL = [[dictionary objectForKey:@"profile_image_url"] stringByReplacingOccurrencesOfString:@"_normal" withString:@"_bigger"];
        self.largeImageURL = [_imageURL stringByReplacingOccurrencesOfString:@"_bigger" withString:@""];
        self.bannerImageURL = [[dictionary objectForKey:@"profile_banner_url"] stringByAppendingString:@"/mobile_retina"];
    }
    
    return self;
}

@end
