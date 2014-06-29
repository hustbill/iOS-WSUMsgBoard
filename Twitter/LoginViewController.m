//
//  LoginViewController.m
//  Twitter
//
//  Created by hua zhang on 4/3/14.
//  Copyright (c) 2014 encs.wsu.edu. All rights reserved.
//

#import "LoginViewController.h"
#import "TwitterAppDelegate.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    //Cancel button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

//Register new user and logs user in
-(IBAction)registerUser:(id)sender {
    NSLog(@"register users!");
    TwitterAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSString *username = self.userField.text;
    NSString *password = self.passwordField.text;
    NSDictionary *parameters = @{@"username": username, @"password": password};
    
    NSURL *baseURL = [NSURL URLWithString:BaseURLString];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:@"register.cgi" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *session_token = [responseObject objectForKey:@"session_token"];
        //NSLog(@"responseobject =%@",token );
        NSLog(@"Register user");
        //(1) save username, passwd, and session_token in app delegate
        
        appDelegate.username = username;
        appDelegate.password = password;
        appDelegate.session_token = session_token;
        
        //(2) inform loginDelegate (probably the master-view-controller) of successful login
        if ([self.loginDelegate respondsToSelector:@selector(didRegister)]) {
            [self.loginDelegate didRegister];
        }
        
        //(3) dismiss this controller (which mas presented modall)
        [self dismissViewControllerAnimated:YES completion:^{}];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) task.response;
        const int statuscode = response.statusCode;
        //
        // Display AlertView with appropriate error message.
        //
        NSString *msg = [appDelegate getAlertMsg: statuscode];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:appDelegate.username
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil, nil];
        [alert setTag:0];
        [alert show];
        NSLog(@"Register user failed! Statuscode =%d", statuscode);


    }];

}


//user login, and add a new tweet for test.
- (IBAction)loginUser:(UIButton *)sender {
   NSLog(@"users login!");
    TwitterAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *username = self.userField.text;
    NSString *password = self.passwordField.text;
    
    NSDictionary *parameters = @{@"username": username, @"password": password, @"action" : @"login"};
    //NSDictionary *parameters = @{@"username": username, @"password": password, @"action" : @"logout"};
    NSURL *baseURL = [NSURL URLWithString:BaseURLString];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:@"login.cgi" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *session_token = [responseObject objectForKey:@"session_token"];
        
        //(1) save username, passwd, and session_token in app delegate
      
        appDelegate.username = username;
        appDelegate.password = password;
        appDelegate.session_token = session_token;
        
        //(2) inform loginDelegate (probably the master-view-controller) of successful login
        if ([self.loginDelegate respondsToSelector:@selector(didLogin)]) {
            [self.loginDelegate didLogin];
        }
        
        //(3) dismiss this controller (which mas presented modall)
        [self dismissViewControllerAnimated:YES completion:^{}];
       
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *) task.response;
        const int statuscode = response.statusCode;
        
        //
        // Display AlertView with appropriate error message.
        //
        NSString *msg = [appDelegate getAlertMsg: statuscode];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:appDelegate.username
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert setTag:0];
        [alert show];
        NSLog(@"login failed! Statuscode =%d", statuscode );

    }];
    
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)cancel:(id)sender{
    if ([self.loginDelegate respondsToSelector:@selector(didCancelLogin)]) {
        [self.loginDelegate didCancelLogin];
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
}


#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 5;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//
//    
//    // Configure the cell...
//    
//    return cell;
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

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
