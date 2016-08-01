
//
//  TwitterMasterViewController.m
//  Twitter
//
//  Created by hua zhang on 4/2/14.
//  Copyright (c) 2014 encs.wsu.edu. All rights reserved.
//

#import "TwitterMasterViewController.h"
#import "TwitterAppDelegate.h"

#import "AddTweetViewController.h"

#import "UIRefreshControl+AFNetworking.h"
#import "UIAlertView+AFNetworking.h"
#import "AFHTTPSessionManager.h"

#define BaseURLString @"http://wsu.twitter.com/cgi-bin"

@interface TwitterMasterViewController () <AddTweetDelegate>
-(void)addTweet:(id)sender;
-(void)login:(id)sender;
-(void)refreshTweets;


@end

@implementation TwitterMasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //use the following line to preserve selection between presentations.
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // the following line to display an Edit button in the navigation bar for this view controller.
    //  Do any additional setup after oading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTweet:)];
    self.navigationItem.rightBarButtonItem = addButton;
    UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:@"👤" style:UIBarButtonItemStylePlain target:self action:@selector(login:)];
    self.navigationItem.leftBarButtonItem = loginButton;
    
    TwitterAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (appDelegate.session_token.length > 3) {
        self.title = appDelegate.username;
    } else {
        self.title = @"Tweets";
    }
    self.loginViewController = (LoginViewController *)[[self.splitViewController.viewControllers lastObject]topViewController];
    self.detailViewController = (AddTweetViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self.refreshControl beginRefreshing];
    //[self fetchNewTweets]; //fetech new tweets when table view was loaded.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

//this method is to access the app delegate and the cached tweets
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    TwitterAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSInteger tweetsCount = appDelegate.tweets.count;
    NSLog(@" tweetsCount=%ld", (long)tweetsCount);
    return tweetsCount;
}

-(NSAttributedString *) tweetAttributedStringFromTweet:(Tweet*)tweet {
    if(tweet.tweetAttributedString ==nil    ){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle  = NSDateFormatterShortStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        NSString *dateString = [dateFormatter stringFromDate:tweet.date];
        //NSLog(@" dateString=%@", dateString);
        NSString *title = [NSString stringWithFormat:@"%@ - %@\n", tweet.username,
                           dateString];
        
        NSDictionary *titleAttributes =
        @{NSFontAttributeName: [UIFont systemFontOfSize:14],
          NSForegroundColorAttributeName :[UIColor blueColor]};
        NSMutableAttributedString  *tweetWithAttributes =
        [[NSMutableAttributedString alloc] initWithString:title attributes:titleAttributes];
        
        NSMutableParagraphStyle *textStyle =
        [[NSMutableParagraphStyle defaultParagraphStyle]mutableCopy];
        textStyle.lineBreakMode = NSLineBreakByCharWrapping;
        textStyle.alignment = NSTextAlignmentLeft;
        
        NSDictionary *bodyAttributes =
        @{NSFontAttributeName: [UIFont systemFontOfSize:17],
          NSForegroundColorAttributeName: [UIColor blackColor],
          NSParagraphStyleAttributeName:textStyle        };
        
        NSAttributedString *bodyWithAttributtes =
        [[NSAttributedString alloc]initWithString:tweet.tweet attributes:bodyAttributes];
        
        [tweetWithAttributes appendAttributedString:bodyWithAttributtes];
        tweet.tweetAttributedString  = tweetWithAttributes;
        
    }
    return tweet.tweetAttributedString;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    TwitterAppDelegate *addDelegate  =  [[UIApplication sharedApplication] delegate];
    
    Tweet *tweet = addDelegate.tweets[indexPath.row];
     NSAttributedString *tweetAttributedString =
        [self tweetAttributedStringFromTweet:tweet];
    
    CGRect tweetRect =
            [tweetAttributedString
              boundingRectWithSize:CGSizeMake(self.tableView.bounds.size.width, 1000.0)
                    options:NSStringDrawingUsesLineFragmentOrigin
                    context:nil ];
    return ceilf(tweetRect.size.height) +1 +20;   //add marginal space
    
}

-(UITableViewCell *) tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"MasterCell";
    //static NSString *CellIdentifier = @"TwitterCell";
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                    forIndexPath:indexPath];
    TwitterAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
     Tweet *tweet = appDelegate.tweets[indexPath.row];
    NSAttributedString *tweetAttributedString =
    [self tweetAttributedStringFromTweet:tweet];
    cell.textLabel.numberOfLines = 0;   //multi-line label
    cell.textLabel.attributedText = tweetAttributedString;
    return cell;
    
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    TwitterAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    Tweet *tweet = appDelegate.tweets[indexPath.row];
    if (appDelegate.username.length <3 ) {
        return NO;
    }
    //With Dr.Cochran's help
    return [appDelegate.username isEqualToString:tweet.username] ;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        TwitterAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        self.detailViewController.detailItem = appDelegate.tweets[indexPath.row];
    }
}


//// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //[_objects removeObjectAtIndex:indexPath.row];
        
        Tweet *tweet = [[Tweet alloc] init ];
        int row =indexPath.row ;
        TwitterAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        tweet =appDelegate.tweets[row];

           NSLog(@" tweet.username =%@ tweet_id=%ld  ", tweet.username, (long) tweet.tweet_id);

        
        if (appDelegate.session_token.length >3 && tweet.username.length >0 ) {
          
            NSURL *baseURL = [NSURL URLWithString:BaseURLString];
            AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            NSLog(@"tweet.tweet_id =%d", tweet.tweet_id);
            NSNumber *tweet_id = [NSNumber numberWithInt:tweet.tweet_id];
            NSDictionary *para = @{@"username": tweet.username , @"session_token": appDelegate.session_token,
                                   @"tweet_id":tweet_id} ;
             manager.responseSerializer = [AFJSONResponseSerializer serializer];
            [manager GET:@"del-tweet.cgi" parameters:para success:^(NSURLSessionDataTask *task, id responseObject) {
                //NSMutableArray *tweet = [responseObject objectForKey:@"tweet"];
                //NSLog(@"responseobject =%@",tweet );
                NSLog(@"call del-tweet.cgi successfully");
                
               [appDelegate.tweets removeObjectAtIndex:indexPath.row];
               [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                if ([self.addTweetDelegate respondsToSelector:@selector(didDeleteTweet)]) {
                    [self.addTweetDelegate didDeleteTweet ];
                }
                [self.tableView reloadData ];
                [self dismissViewControllerAnimated:YES completion:^{}];
                
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSHTTPURLResponse *response = (NSHTTPURLResponse *) task.response;
                const int statuscode = response.statusCode;
                NSLog(@"statuscode = %d", statuscode);
                
                UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Error"
                                                               message:@"Bad Request or Unauthorized!"
                                                              delegate:self cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:nil, nil];
                [alert setTag:2];
                [alert show];
                //
                // Display AlertView with appropriate error message.
                //
            }];
           } else{
            NSLog(@"Please login in first!");
            UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Login"
                                                           message:@"Please Sign in first!"
                                                          delegate:self cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"Sign in", nil];
            [alert setTag:1];
            [alert show];
        }
   
    }
}

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


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"viewTweetSegue"]) {
        NSIndexPath  *indexPath = [self.tableView indexPathForSelectedRow];
        TwitterAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        Tweet *tweet =  appDelegate.tweets[indexPath.row];
        AddTweetViewController *detailViewController =  segue.destinationViewController;
        detailViewController.detailItem = tweet;
        detailViewController.addTweetDelegate = self;
        
    }else if ([[segue identifier] isEqualToString:@"addTweetSegue"]){
        UINavigationController *navController = segue.destinationViewController;
        AddTweetViewController *detailViewController =
        (AddTweetViewController *)navController.topViewController;
        detailViewController.addTweetDelegate =self;
        
    }
    else if ([[segue identifier] isEqualToString:@"deleteTweetSegue"]){
        UINavigationController *navController = segue.destinationViewController;
        AddTweetViewController *detailViewController =
        (AddTweetViewController *)navController.topViewController;
        detailViewController.addTweetDelegate =self;
        
    }
    else if ([[segue identifier] isEqualToString:@"loginSegue"]){
        UINavigationController *navController = segue.destinationViewController;
        LoginViewController *loginViewController =
            (LoginViewController *)navController.topViewController;
            loginViewController.loginDelegate = self;
    }
    
    else if ([[segue identifier] isEqualToString:@"logoutSegue"]){
        NSLog(@"sign out");
        UINavigationController *navController = segue.destinationViewController;
        LoginViewController *loginViewController =
        (LoginViewController *)navController.topViewController;
        loginViewController.loginDelegate = self;
        
    }
    
}

-(void) login:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Welcome to WSUV Twitter."
                                                    delegate:self
                                                    cancelButtonTitle:@"cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Sign in",
                                                    @"Sign out",
                                                    @"Reset user password",
                             
                                  nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        NSLog(@"Cancel Button");
    } else {
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Sign in"]) {
            NSLog(@"Sign in");
            [self performSegueWithIdentifier:@"loginSegue" sender:self];
            
        } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Sign out"]) {
            NSLog(@"Sign out");
            [self didLogout];
            
        }   else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Reset user password"]) {
            NSLog(@"Reset user password");
            [self viewDidLoad];
        }
    }
    
}


-(void)logout:(id)sender{
    
    //(1) read username, passwd, and session_token from  app delegate
    TwitterAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (appDelegate.username.length > 0 && appDelegate.session_token.length>3) {
        
        NSString *username =  appDelegate.username;
        NSString *password = appDelegate.password;
        
        NSDictionary *parameters = @{@"username": username, @"password": password, @"action" : @"logout"};
        
        NSURL *baseURL = [NSURL URLWithString:BaseURLString];
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        [manager GET:@"login.cgi" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            
            //dismiss this controller (which mas presented modall)
            [self dismissViewControllerAnimated:YES completion:^{}];
            
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *) task.response;
            const int statuscode = response.statusCode;
            NSLog(@"statuscode =%d", statuscode);
            
            //
            // Display AlertView with appropriate error message.
            //
        }];
        //set the user info to empty
        appDelegate.username = @"";
        appDelegate.session_token = @"";
        appDelegate.password =@"";
    } else {
        NSLog(@"User does not login, no need logout!");
    }
}

-(void) addTweet:(id)sender{
    [self performSegueWithIdentifier:@"addTweetSegue" sender:self];
}

-(void)didCancelAddTweet{
    NSLog(@"didCancelAddTweet");
}

-(void) deleteTweet:(id)sender{
    [self performSegueWithIdentifier:@"deleteTweetSegue" sender:self];
}


//the tweet are returned from the server  in an array of NSDictionary - ond dictionary per tweet
-(NSDictionary *)conductStrFromDate  {
    NSDictionary *parameters;
    TwitterAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"PST"];
    NSDate *lastTweetDate = [appDelegate lastTweetDate];
    if (lastTweetDate != nil) {
        //NSDate *lastTweetDate =[dateFormatter dateFromString:@"2014-04-10 13:58:28"];
        NSString *dataStr = [dateFormatter stringFromDate:lastTweetDate];
        parameters = @{@"date": dataStr};
    } else {
        parameters = nil;
    }
    
    return parameters;
}

#pragma mark - Table View Data source
//Initiate HTTP/GET to fetch new tweets from server.
//the tweet are returned from the server  in an array
// of NSDictionary - ond dictionary per tweet
-(void)refreshTweets {
    NSDictionary *parameters;
    TwitterAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (appDelegate.tweets.count > 0) {
            parameters = [self conductStrFromDate];
            [appDelegate.tweets removeAllObjects]; //remove all objects before fetch new tweets
    } else {
        parameters = nil;
    }
    
    NSURL *baseURL = [NSURL URLWithString:BaseURLString];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:@"get-tweets.cgi" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *arrayOfDicts = [responseObject objectForKey:@"tweets"];
        //
        // Add new (sorted) tweets to head of appDelegate.tweets array.
        // If implementing delete, some older tweets my be purged.
        // Invoke [self.tableView reloadData] if any changes.
        for (int i= 0; i< arrayOfDicts.count; i++) {
            NSDictionary  *dict =[arrayOfDicts objectAtIndex:i];
            // NSLog(@"%@", dict);
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"PST"];
            Tweet *tweet = [[Tweet alloc] init];
            tweet.date = [dateFormatter dateFromString:[dict objectForKey:@"time_stamp"]];
            tweet.username = dict[@"username"];
            NSString *a = dict[@"tweet_id"];
            tweet.tweet_id = [ a integerValue];
            //NSLog(@" tweet.username =%@ tweet_id=%d  ", tweet.username, tweet.tweet_id);
            tweet.tweet = dict[@"tweet"];
            tweet.isdeleted =[dict[@"isdeleted"] boolValue];
            if (tweet.isdeleted !=1 ) {   //doesn't display the tweet which the flag "isdeleted" =1
                [appDelegate.tweets  addObject:tweet];
            }
        }
        //sort  tweets of appDelegate.tweets array, order by "_date" not by "tweet.date" !!
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"_date" ascending:NO];
        [appDelegate.tweets sortUsingDescriptors:[NSMutableArray arrayWithObjects:descriptor,nil]];
        [self.tableView reloadData ];
        [self.refreshControl endRefreshing];
        NSLog(@"fetch new tweets successfully!");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) task.response;
        const int statuscode = response.statusCode;
        NSLog(@"statuscode =%d", statuscode);
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
        NSLog(@"fetch new tweets failure!");
    }];
}


-(IBAction)refreshControlValueChanged:(UIRefreshControl *)sender {
    [self refreshTweets];
}

-(void)didAddTweet{
    [self.refreshControl beginRefreshing];
    [self refreshTweets];
}

-(void)didDeleteTweet{
    [self.refreshControl beginRefreshing];
   [self refreshTweets];
}

-(void)didEditTweet{
    NSLog(@"didEditTweet");
       [self.tableView reloadData];
    
}


-(void)didCancelLogin{
    NSLog(@"didCancelLogin");
}


-(void)didLogin {
    TwitterAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.title = appDelegate.username;
}


-(void)didLogout {
    TwitterAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:appDelegate.username
                                                    message:@"Are you sure you want to sign out of Twitter?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Sign out", nil];
    [alert setTag:0];
    [alert show];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([actionSheet tag] == 0) {
        NSLog(@"actionSheet tag == 0");
        
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Sign out"]) {
            NSLog(@"Sign out");
            [self logout:self];
            TwitterAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

            if ( appDelegate.username.length > 0) {
                NSLog(@"%@", appDelegate.username);
                self.title = appDelegate.username;
            } else {
                 self.title = @"tweets";
            }

        }
    }
    
    if ([actionSheet tag] == 1) {
        NSLog(@"actionSheet tag == 1");
        
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Sign in"]) {
            NSLog(@"Sign in");
            [self login:self];
            TwitterAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            
            if ( appDelegate.username.length > 0) {
                NSLog(@"%@", appDelegate.username);
                self.title = appDelegate.username;
            } else {
                self.title = @"tweets";
            }
            
        }
    }
}


-(void)didRegister{
    TwitterAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.title = appDelegate.username;
}
@end
