//
//  TwitterAppDelegate.m
//  twitter
//
//  Created by hua zhang on 4/1/14.
//  Copyright (c) 2014 encs.wsu.edu. All rights reserved.
//

#import "TwitterAppDelegate.h"
#import "Tweet.h"
#import "TwitterMasterViewController.h"

#import "UIRefreshControl+AFNetworking.h"
#import "UIAlertView+AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import "AFNetworking.h"

#define BaseURLString @"http://wsu.twitter.com/cgi-bin"

#define kTweetsKey @"tweets"

@implementation TwitterAppDelegate

-(NSString *)pathToArchive {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    return [docDir stringByAppendingPathComponent:@"tweets.archive"];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate =(id)navigationController.topViewController;
    }
    
    NSString *arhivePath = [self pathToArchive];
    if([[NSFileManager defaultManager] fileExistsAtPath:arhivePath]){
        NSData *data = [[NSData alloc] initWithContentsOfFile:arhivePath];
        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        NSArray *a = [decoder decodeObjectForKey:kTweetsKey];
        [decoder finishDecoding];
        self.tweets = [a mutableCopy];
    } else {
        Tweet *tweet = [[Tweet alloc] init];
        tweet.username = @"Bill";
         tweet.tweet_id = 26;
         tweet.tweet = @"Like Me in Appstore";
         tweet.date = [NSDate distantPast];
        
        self.tweets = [[NSMutableArray alloc] initWithArray:@[tweet]];
    }
    
     return YES;
}

-(NSDate *)lastTweetDate {
    
    NSDate *date;
    //lastobject in self.tweets
    Tweet *tweet;
    if (self.tweets.count >0 ) {
        tweet= self.tweets.lastObject;
        NSLog(@"tweet.date= %@ tweet_id =%d", tweet.date , tweet.tweet_id);
        date= tweet.date;
    } else {
        date = [NSDate distantPast];
    }
    return date;
}


-(NSString *)getAlertMsg: (int)statuscode {
    NSString *msg = @" ";
    
    switch (statuscode) {
            
        case  400:
            msg = @"Bad Request: both username and password not provided, or missing parameters!" ;
            break;
        case  401:
            msg = @"Unauthorized: Unauthorized";
            break;
        case  403:
            msg = @"Forbidded: not the user's tweet";
            break;
        case  404:
            msg = @"Not Found: not such user or no such tweet"  ;
            break;
        case  409:
            msg = @"Conflict: username already exists"  ;
            break;
        case  500:
            msg = @"Internal Server Error: my bad";
            break;
        case  503:
            msg = @"Database Unavailable: unable to connect to internal database";
            break;
            
        default:
            msg = @"Error, please check the Internet connection!";
            break;
    }
    
    return msg;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [coder encodeObject:self.tweets forKey:kTweetsKey];
    [coder finishEncoding];
    NSString *archivePath = [self pathToArchive];
    [data writeToFile:archivePath atomically:YES];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
