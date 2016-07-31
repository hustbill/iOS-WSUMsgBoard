# WSUV ENCS Message Board   
Start at March 30, 2014  

For this project we will create a client iOS application for a Twitter-like service.   
User information and messages are stored on a server and are accessible via a web-based API using HTTP GET/POST methods.   We will use the delightful AFNetworking framework to communicate with the server.   

## Features:
Our application will allow the user to :  
• fetch and view the latest “tweets”,  
• authenticate (register, log-on, and log-off),  
• post messages (authenticated users only), and  
• delete messages that the user posted (bonus feature).  

## Tech Topics:  
The project covers a variety of topics:  
• UI controllers and views,  
• keyboard input and user interaction,  
• data persistence including using the iOS Keychain for secure storage of user information, and  
• HTTP GET/POST communication with a RESTful API via AFNetworking.  


##  Model Objects  
| Property |      description                    |
|----------|:-----------------------------------:|
| tweet_id |  unique integer identifying tweet   |
| username |    string of user who posted tweet  |
| isdeleted| true iff this tweet has been deleted|
|tweet     | content of tweet (NSString)         |
|date      | time/date stamp of tweet (NSDate)   | 
 
Table 1: Tweet object fields.  

The tweets are stored remotely on the server, but are cached in a local array. The application delegate
is a convenient place to store the tweets since it persists for the lifetime of the app, is easily accessible by all
view controllers, and already has the hooks in place for loading and storing the tweets in the app’s sandbox
when the app launches and enters the background state. The example method below (from my main table
view controller) demonstrates the pattern for accessing the app delegate and the cached tweets:  

```code
override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
   return appDelegate.tweets.count
}
```
