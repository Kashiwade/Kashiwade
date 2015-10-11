//
//  KashiwadeDB.m
//  Kashiwade
//
//  Created by gotojo on 2015/10/11.
//  Copyright © 2015年 LoopSessions. All rights reserved.
//

#import "KashiwadeDB.h"
#import "NCMB/NCMB.h"

@interface KashiwadeDB ()
{
    NSMutableDictionary* kashiwadeData;
    NSMutableDictionary* incValue;
}
@end

@implementation KashiwadeDB

+ (KashiwadeDB*)instance
{
    static KashiwadeDB* instance=0;
    if (instance==0) instance = [[self alloc] init];
    return instance;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        [NCMB setApplicationKey:@"1be9dba7dec777026b5832322db9e5882f8e1cd5ed76fb7e45848657aa6c7ad3" clientKey:@"af6b5030e091b942a843f099084821cd911e866622065d8f8c3a57c200f3dc3a"];
        kashiwadeData=[[NSMutableDictionary alloc] init];
        [kashiwadeData setObject:@0 forKey:@"真鶴1"];
        [kashiwadeData setObject:@0 forKey:@"真鶴2"];
        [kashiwadeData setObject:@0 forKey:@"新宿"];
        [kashiwadeData setObject:@0 forKey:@"ビッグサイト"];
        [kashiwadeData setObject:@0 forKey:@"ポケモンセンター"];
        [self getKashiwadeData];
        incValue=[[NSMutableDictionary alloc] init];
        [incValue setObject:@0 forKey:@"真鶴1"];
        [incValue setObject:@0 forKey:@"真鶴2"];
        [incValue setObject:@0 forKey:@"新宿"];
        [incValue setObject:@0 forKey:@"ビッグサイト"];
        [incValue setObject:@0 forKey:@"ポケモンセンター"];
        [NSTimer
         scheduledTimerWithTimeInterval:1.0f
         target:self
         selector:@selector(sync:)
         userInfo:nil
         repeats:YES
        ];
    }
    return self;
}

- (void)getKashiwadeData
{
    NCMBQuery *query = [NCMBQuery queryWithClassName:@"kashiwade"];
    for (id key in kashiwadeData) {
        [query whereKey:@"title" equalTo:key];
        [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
            for (NCMBObject *post in posts) {
                [kashiwadeData setObject:[post objectForKey:@"num"] forKey:key];
                // 再取得
                [post refresh:nil];
            }
        }];
    }
}

- (void)sync:(NSTimer*)timer
{
    NCMBQuery *query = [NCMBQuery queryWithClassName:@"kashiwade"];
    for (id key in kashiwadeData) {
        [query whereKey:@"title" equalTo:key];
        [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
            for (NCMBObject *post in posts) {
                int num=[[post objectForKey:@"num"] intValue];
                int inc= [[incValue objectForKey:key] intValue];
                int cur=[self getNum:key];
                if (num==cur&&inc==0) continue;
                num+=inc;
                [kashiwadeData setObject:[NSNumber numberWithInt:num] forKey:key];
                [incValue setObject:@0 forKey:key];
                [post setObject:[NSNumber numberWithInt:num] forKey:@"num"];
                [post saveInBackgroundWithBlock:nil];

                [[NSNotificationCenter defaultCenter] postNotificationName:@"DataUpdated"
                                                                    object:self
                                                                  userInfo:@{@"key":key}];
                 
                // 再取得
                [post refresh:nil];
            }
        }];
    }
}

- (int)getNum:(NSString*)key
{
    return [[kashiwadeData objectForKey:key] intValue];
}

- (int)incNum:(NSString*)key
{
    int num=[self getNum:key];
    num++;
    [kashiwadeData setObject:[NSNumber numberWithInt:num] forKey:key];
    int inc= [[incValue objectForKey:key] intValue];
    inc++;
    [incValue setObject:[NSNumber numberWithInt:inc] forKey:key];
    return num;
}
+ (int)getNum:(NSString*)key
{
    return [[KashiwadeDB instance] getNum:key];
}
+ (int)incNum:(NSString*)key
{
    return [[KashiwadeDB instance] incNum:key];
}
@end
