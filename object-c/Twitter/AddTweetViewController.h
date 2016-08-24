//
//  AddTweetViewController.h
//  Twitter
//
//  Created by hua zhang on 4/2/14.
//  Copyright (c) 2014 encs.wsu.edu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitterAppDelegate.h"

#import "Tweet.h"

@protocol AddTweetDelegate <NSObject>
@optional
-(void)didCancelAddTweet;
-(void)didAddTweet;
-(void)didDeleteTweet;
-(void)didEditTweet;
@end

@interface AddTweetViewController : UITableViewController <UISplitViewControllerDelegate,
UITextViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic)id<AddTweetDelegate> addTweetDelegate;
@property (strong, nonatomic)Tweet *detailItem;

@property (weak, nonatomic)IBOutlet UITextField *subjectTextField;
@property (weak, nonatomic)IBOutlet UISegmentedControl *prioritySegmentedControl;
@property (weak, nonatomic)IBOutlet  UITextView *tweetTextView;

@end

