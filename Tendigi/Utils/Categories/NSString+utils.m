//
//  NSString+utils.m
//  Tendigi
//
//  Created by Lionel on 06/02/2015.
//  Copyright (c) 2015 Lionel. All rights reserved.
//

#import "NSString+utils.h"

@implementation NSString (utils)

- (NSDate *)twitterDate {
    NSString *dateStr = self;
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:locale];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    
    return date;
}

@end
