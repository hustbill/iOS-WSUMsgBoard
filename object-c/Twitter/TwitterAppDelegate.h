//
//  TwitterAppDelegate.h
//  twitter
//
//  Created by hua zhang on 4/1/14.
//  Copyright (c) 2014 encs.wsu.edu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@interface TwitterAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic)NSMutableArray *tweets;
@property (strong, nonatomic)NSString *username;
@property (strong, nonatomic)NSString *password;
@property (strong, nonatomic)NSString *tweet;
@property (strong, nonatomic)NSString *session_token;
@property (copy, nonatomic) NSString *refreshDateString;
@property NSInteger *tweet_id;


-(NSDate *)lastTweetDate;
//return the error message based on statuscode.
-(NSString *)getAlertMsg: (int)statuscode;

@end
