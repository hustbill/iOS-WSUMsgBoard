//
//  LoginViewController.h
//  Twitter
//
//  Created by hua zhang on 4/3/14.
//  Copyright (c) 2014 encs.wsu.edu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIRefreshControl+AFNetworking.h"
#import "UIAlertView+AFNetworking.h"
#import "AFHTTPSessionManager.h"

#define BaseURLString @"https://bend.encs.vancouver.wsu.edu/~wcochran/cgi-bin"


@protocol LoginDelegate <NSObject>
@optional
-(void)didLogin;
-(void)didLogout;
-(void)didCancelLogin;
-(void)didRegister;

@end


@interface LoginViewController : UITableViewController  <UISplitViewControllerDelegate,
UITextViewDelegate, UITextFieldDelegate>


@property (weak, nonatomic)id<LoginDelegate> loginDelegate;

@property (weak, nonatomic)IBOutlet UITextField *userField;
@property (weak, nonatomic)IBOutlet UITextField *passwordField;
@property (weak, nonatomic)IBOutlet  UITextView *tweetTextView;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
-(void)cancel:(id)sender;

@end


