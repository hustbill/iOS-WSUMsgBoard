//
//  Twitter.h
//  Twitter
//
//  Created by hua zhang on 4/2/14.
//  Copyright (c) 2014 encs.wsu.edu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tweet : NSObject <NSCoding, NSCopying>
@property (assign, nonatomic)NSInteger  tweet_id;  //unique integer identifying tweet
@property (copy, nonatomic)NSString *username; //string of user who posted tweet
@property (assign, nonatomic)BOOL isdeleted;  //true if this tweet has been deleted.
@property (copy, nonatomic)NSString *tweet;   //content of tweet
@property (retain, nonatomic)NSDate *date;    //time/date stamp of tweet
@property (copy, nonatomic)NSAttributedString *tweetAttributedString; //formatted tweet

-(id)init;
-(id)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)copyWithZone:(NSZone *)zone;
-(instancetype)initWithItemName:(int) tweet_id
                       username:(NSString *) username
                          tweet:(NSString *)tweet;

@end
