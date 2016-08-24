//
//  Twitter.m
//  Twitter
//
//  Created by hua zhang on 4/2/14.
//  Copyright (c) 2014 encs.wsu.edu. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet
/*
 
 @property (assign, nonatomic)NSInteger  tweet_id;  //unique integer identifying tweet
 @property (copy, nonatomic)NSString *username; //string of user who posted tweet
 @property (assign, nonatomic)BOOL isdeleted;  //true if this tweet has been deleted.
 @property (copy, nonatomic)NSString *tweet;   //content of tweet
 @property (retain, nonatomic)NSDate *date;    //time/date stamp of tweet
 @property (copy, nonatomic)NSAttributedString *tweetAttributedString; //formatted tweet
 */

-(id)init { //init tweet model
    if (self =[super init]) {
        self.tweet_id = 1;
        self.username = @"";
        self.isdeleted = NO;
        self.tweet = @"";
        self.date = [NSDate date];
        self.tweetAttributedString = nil;
        
    }
    return self;
}

-(instancetype)initWithItemName:(int) tweet_id
                       username:(NSString *) username
                          tweet:(NSString *)tweet { //init specific tweet
    //Call the superclass's designated initializer
    self =[super init];
    
    //Did the superclass's designated initialier succeed?
    if (self) {
        // Give the instance  variables initial values
        self.tweet_id = tweet_id;
        self.username = username;
        self.isdeleted = NO;
        self.tweet = tweet;
        self.date = [[NSDate alloc]init];
        self.tweetAttributedString = nil;
        
    }
    return self;
}

#define kTweet_idKey @"tweet_id"
#define kUserNameKey @"username"
#define kIsDeletedKey @"isdeleted"
#define kTweetKey @"tweet"
#define kDateKey @"date"
#define ktweetAttributedStringKey @"tweetAttributedString"


-(id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]){
        self.tweet_id = [aDecoder decodeIntegerForKey:kTweet_idKey ];
        self.username = [aDecoder decodeObjectForKey:kUserNameKey];
        self.isdeleted = [aDecoder decodeBoolForKey:kIsDeletedKey];
        self.tweet = [aDecoder decodeObjectForKey:kTweetKey];
        self.date = [aDecoder decodeObjectForKey:kDateKey];
        self.tweetAttributedString = [aDecoder decodeObjectForKey:ktweetAttributedStringKey];

    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInteger:self.tweet_id forKey:kTweet_idKey];
    [aCoder encodeObject:self.username forKey:kUserNameKey];
    [aCoder encodeBool:self.isdeleted forKey:kIsDeletedKey];
    [aCoder encodeObject:self.tweet forKey:kTweetKey ];
    [aCoder encodeObject:self.date forKey:kDateKey];
    [aCoder encodeObject:self.tweetAttributedString forKey:ktweetAttributedStringKey ];
    
}

-(id)copyWithZone:(NSZone *)zone {
    Tweet *clone = [[[self class] alloc] init];
    clone.tweet_id  = self.tweet_id;
    clone.username = self.username;
    clone.isdeleted = self.isdeleted;
    clone.tweet = self.tweet;
    clone.date    = self.date;
    clone.tweetAttributedString = self.tweetAttributedString;
    return clone;
}

@end
