
//
//  AddTweetViewController.m
//  Twitter
//
//  Created by hua zhang on 4/2/14.
//  Copyright (c) 2014 encs.wsu.edu. All rights reserved.
//

#import "AddTweetViewController.h"
#import "TwitterAppDelegate.h"
#import "LoginViewController.h"
#import "Tweet.h"


#import "UIRefreshControl+AFNetworking.h"
#import "UIAlertView+AFNetworking.h"
#import "AFHTTPSessionManager.h"

#define BaseURLString @"https://bend.encs.vancouver.wsu.edu/~wcochran/cgi-bin"


@interface AddTweetViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
-(void)configureView;
-(void)cancel:(id)sender;
-(void)doneAdding:(id)sender;
@end

@implementation AddTweetViewController {
    BOOL _isDirty;   //tweet has been edited?
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark  - Managing the detail item
-(void)setDetailItem:(Tweet *) newDetailItem {
    if(_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        //Update the view.
        [self configureView];
    }
    if (self.masterPopoverController !=nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

-(void)cancel:(id)sender{
    if ([self.addTweetDelegate respondsToSelector:@selector(didCancelAddTweet)]) {
        [self.addTweetDelegate didCancelAddTweet];
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
}




-(void)doneAdding:(id)sender{
    // Validate the Form
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedTweetText = [self.tweetTextView.text stringByTrimmingCharactersInSet:whitespace];
    if (trimmedTweetText.length <= 0 ){
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Incomplete Form!"
                                                       message:@"Please fill out entire Form"
                                                      delegate:nil cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    TwitterAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    Tweet *tweet = [[Tweet alloc] init ];
    tweet.tweet = self.tweetTextView.text;
    tweet.username = appDelegate.username;
     Tweet *lastTweet =  appDelegate.tweets.lastObject;
    //NSInteger *last_tweetID = lastTweet.tweet_id;
    tweet.tweet_id =  lastTweet.tweet_id + 1;  //add tweet to the head of appDelegate
    if (appDelegate.session_token.length >3 && tweet.username.length >0 ) {
        [appDelegate.tweets insertObject:tweet atIndex:0];
        
        NSURL *baseURL = [NSURL URLWithString:BaseURLString];
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        NSDictionary *para = @{@"username": tweet.username , @"session_token": appDelegate.session_token, @"tweet" : tweet.tweet};
        //NSLog(@"username=%@  tweet=%@ ", tweet.username, tweet.tweet);
        [manager POST:@"add-tweet.cgi" parameters:para success:^(NSURLSessionDataTask *task, id responseObject) {
            //NSMutableArray *tweet = [responseObject objectForKey:@"tweet"];
            NSLog(@"call add-tweet.cgi successfully!");
            if ([self.addTweetDelegate respondsToSelector:@selector(didAddTweet)]) {
                [self.addTweetDelegate didAddTweet ];
            }
            [self dismissViewControllerAnimated:YES completion:^{}];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *) task.response;
            const int statuscode = response.statusCode;
            NSLog(@"statuscode = %d", statuscode);
            //
            // Display AlertView with appropriate error message.
            //
            NSString *msg = [appDelegate getAlertMsg: statuscode ];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:appDelegate.username
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert setTag:0];
            [alert show];
            [self.refreshControl endRefreshing];
            NSLog(@"add a new tweet failure!");
            
        }];
        
    } else{
        NSLog(@"Please login in first!");
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Login"
                                                       message:@"Please Sign in first!"
                                                      delegate:self cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"Sign in", nil];
        [alert setTag:0];
        [alert show];
    }
}


- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([actionSheet tag] == 0) {
        NSLog(@"actionSheet tag == 0");
        
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Sign in"]) {
            NSLog(@"Sign in");
            
            [self performSegueWithIdentifier:@"loginSegue" sender:self];
            
        }else {
            NSLog(@"actionSheet tag != 0 buttonIndex != cancelButtonIndex:%d", buttonIndex != [actionSheet cancelButtonIndex]);
            if (buttonIndex != [actionSheet cancelButtonIndex]) { // Yes
                 NSLog(@"Yes");
            
            }
        }
    }     
}


-(void)makeControlsEditable:(BOOL)flag {
    self.subjectTextField.enabled =flag;
    self.prioritySegmentedControl.enabled = flag;
    self.tweetTextView.editable = flag;
    const UITextBorderStyle borderStyle = flag ? UITextBorderStyleRoundedRect :UITextBorderStyleNone;
    self.subjectTextField.borderStyle = borderStyle;
    if (flag) {
        [self.subjectTextField becomeFirstResponder];
    }
}


-(void) configureView {
    //Update the user interface for the detail item.
    if (self.detailItem) {
        self.tweetTextView.text = self.detailItem.tweet;
            self.navigationItem.rightBarButtonItem = self.editButtonItem;
        

         [self makeControlsEditable:NO];
        _isDirty = NO;
    } else {
        // note: iphone only
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                             target:self action:@selector(cancel:)];
            self.navigationItem.leftBarButtonItem = cancelButton;
            
            UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                           target:self action:@selector(doneAdding:)];
            self.navigationItem.rightBarButtonItem  = doneButton;
        
        } else { //iPad
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                                   target:self action:nil];
            [self makeControlsEditable:NO];
            _isDirty = NO;

        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView ];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

-(void)viewDidAppear:(BOOL)animated {
    if (self.detailItem == nil) {
        [self.tweetTextView becomeFirstResponder];
    }
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated ];
    [self makeControlsEditable:editing];
    if (!editing && _isDirty) { //form validation?
        self.detailItem.username = self.subjectTextField.text;
        self.detailItem.tweet_id = self.prioritySegmentedControl.selectedSegmentIndex +1;
        self.detailItem.tweet = self.tweetTextView.text;
        if ([self.addTweetDelegate respondsToSelector:@selector(didEditTweet)]) {
            [self.addTweetDelegate didEditTweet];
        }
    }
}


-(void)textViewDidChange:(UITextView *)textView {
    _isDirty = YES;
}

- (IBAction)prioritySegmentControllerValueChanged:(id)sender {
    _isDirty = YES;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    
//    // Return the number of sections.
//    return 0;
//}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    // Return the number of rows in the section.
//    return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    
    return NO;
}

#pragma mark - Split view
//-(void)spliViewController:(UISplitViewController *)splitController
//    willHidenView
//
//;

-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController  = pc;
    
}

- (void)splitViewController:(UISplitViewController *)splitController
     willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

@end

