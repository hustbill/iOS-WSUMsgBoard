//
//  TwitterMasterViewController.h
//  Twitter
//
//  Created by hua zhang on 4/2/14.
//  Copyright (c) 2014 encs.wsu.edu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddTweetViewController.h"

#import "LoginViewController.h"
#import "Tweet.h"

@interface TwitterMasterViewController : UITableViewController <LoginDelegate>
-(void)logout:(id)sender;
-(void)login:(id)sender;
-(void) addTweet:(id)sender;

@property (weak, nonatomic)id<AddTweetDelegate> addTweetDelegate;


@property TwitterMasterViewController *masterViewController;

@property AddTweetViewController *detailViewController;
@property LoginViewController *loginViewController;


@property (strong, nonatomic)Tweet *tweet;
@property (strong, nonatomic)Tweet *detailItem;




@end
