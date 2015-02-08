//
//  LALTwitterManager.m
//  Tendigi
//
//  Created by Lionel on 06/02/2015.
//  Copyright (c) 2015 Lionel. All rights reserved.
//

#import "LALTwitterManager.h"

#define kTwitterAccount @"tendigi"
#define kTwitterBaseURL @"https://api.twitter.com/1.1"

@interface LALTwitterManager ()

@property (strong, nonatomic) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccount* account;

@end

@implementation LALTwitterManager

+ (LALTwitterManager *)sharedManager {
    static LALTwitterManager *dataManager;
    static dispatch_once_t token;
    dispatch_once (&token, ^{
        dataManager = [[self alloc] init];
    });
    
    return dataManager;
}

- (id)init {
    if (self = [super init]) {
        self.accountStore = [[ACAccountStore alloc] init];
    }
    
    return self;
}

- (void)accessToTwitterAccountWithCompletionBlock:(void(^)())completionBlock {
    
    ACAccountType *twitterAccountType = [self.accountStore
                                         accountTypeWithAccountTypeIdentifier:
                                         ACAccountTypeIdentifierTwitter];
    
    dispatch_async(dispatch_get_global_queue(
                                             DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:nil completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 NSArray *twitterAccounts = [self.accountStore
                                             accountsWithAccountType:twitterAccountType];
                 self.account = [twitterAccounts lastObject];
             }

             if (self.account) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if(completionBlock) {
                         completionBlock();
                     }
                 });
             }
             else {
                 [self showError:@"Please make sure you have a Twitter account set up in Settings. Also grant access to this app"];
             }
         }];
    });
    
}

- (void)getTwitterUserWithCompletionBlock:(void(^)(NSDictionary *jsonResponse, TwitterErrorType error))completionBlock {
    [self checkAccountWithCompletionBlock:^{
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/show.json", kTwitterBaseURL]];
        NSDictionary *params = @{@"screen_name" : kTwitterAccount};
        
        [self performTwitterRequestWithUrl:url params:params completionBlock:completionBlock];
    }];
}

- (void)getTwitterFeedsWithMaxId:(NSNumber *)maxId completionBlock:(void (^)(NSArray* jsonResponse, TwitterErrorType error))completionBlock {
    [self checkAccountWithCompletionBlock:^{
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/statuses/user_timeline.json", kTwitterBaseURL]];
        NSMutableDictionary* params = [@{@"count" : @"50", @"screen_name" : kTwitterAccount} mutableCopy];
        if (maxId) {
            [params setObject:maxId forKey:@"max_id"];
        }
        [self performTwitterRequestWithUrl:url params:params completionBlock:completionBlock];
    }];
}

#pragma mark - Utils

- (void)performTwitterRequestWithUrl:(NSURL *)url params:(NSDictionary *)params completionBlock:(void(^)(id jsonResponse, TwitterErrorType error))completionBlock {
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:url parameters:params];
    request.account = self.account;
    [request performRequestWithHandler:^(NSData *responseData,
                                         NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            [self showError:[error localizedDescription]];
            TwitterErrorType errorType = error.code == NSURLErrorNotConnectedToInternet ? TwitterErrorTypeNoNetwork : TwitterErrorTypeUnknown;
            dispatch_async(dispatch_get_main_queue(), ^{
                if(completionBlock) {
                    completionBlock(nil, errorType);
                }
            });
        }
        else {
            NSError *jsonError;
            id responseJSON = [NSJSONSerialization
                                     JSONObjectWithData:responseData
                                     options:NSJSONReadingAllowFragments
                                     error:&jsonError];
            
            if (jsonError) {
                [self showError:[jsonError localizedDescription]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(completionBlock) {
                        completionBlock(nil, TwitterErrorTypeUnknown);
                    }
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(completionBlock) {
                        completionBlock(responseJSON, TwitterErrorTypeNone);
                    }
                });
            }
        }
    }];
}

- (void)checkAccountWithCompletionBlock:(void(^)())completionBlock {
    if(!self.account) {
        [self accessToTwitterAccountWithCompletionBlock:completionBlock];
    }
    else {
        if(completionBlock) {
            completionBlock();
        }
    }
}

- (void)showError:(NSString *)errorMessage {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [alertView show];
    });
}

@end
