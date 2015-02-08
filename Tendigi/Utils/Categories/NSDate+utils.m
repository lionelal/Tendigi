//
//  NSDate+utils.m
//  Tendigi
//
//  Created by Lionel on 08/02/2015.
//  Copyright (c) 2015 Lionel. All rights reserved.
//

#import "NSDate+utils.h"

@implementation NSDate (utils)

- (NSString *) stringValue {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM. YYYY"];
    return [dateFormatter stringFromDate:self];
}

@end
