//
//  KashiwadeDB.m
//  Kashiwade
//
//  Created by gotojo on 2015/10/11.
//  Copyright © 2015年 LoopSessions. All rights reserved.
//

#import "KashiwadeDB.h"
#import <Firebase/Firebase.h>

@interface KashiwadeDB ()
{
    NSMutableDictionary* kashiwadeData;
    BOOL is1st;
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
        kashiwadeData=[[NSMutableDictionary alloc] init];
        [kashiwadeData setObject:@0 forKey:@"真鶴1"];
        [kashiwadeData setObject:@0 forKey:@"真鶴2"];
        [kashiwadeData setObject:@0 forKey:@"新宿"];
        [kashiwadeData setObject:@0 forKey:@"ビッグサイト"];
        [kashiwadeData setObject:@0 forKey:@"ポケモンセンター"];
        Firebase *myRootRef = [[Firebase alloc] initWithUrl:@"https://kashiwade.firebaseio.com"];
        is1st=YES;
        [myRootRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
           for (id key in [snapshot.value keyEnumerator]) {
               NSLog(@"Key:%@ Value:%@", key, snapshot.value[key][@"count"]);
               NSLog(@"Key:%@ Value:%@", key, kashiwadeData[key]);
               if (snapshot.value[key][@"count"]!=kashiwadeData[key]) {
                   [kashiwadeData setObject:snapshot.value[key][@"count"] forKey:key];
                   if (is1st) continue;
                   [[NSNotificationCenter defaultCenter] postNotificationName:@"DataUpdated"
                                                                    object:self
                                                                     userInfo:@{@"key":key}];
               }
            }
            is1st=NO;
        }];
    }
    return self;
}

- (int)getNum:(NSString*)key
{
    return [[kashiwadeData objectForKey:key] intValue];
}

- (int)incNum:(NSString*)key
{
    int num=[self getNum:key];
    num++;
    [kashiwadeData setObject:[NSNumber numberWithInteger:num] forKey:key];
    Firebase *myRootRef = [[Firebase alloc] initWithUrl:@"https://kashiwade.firebaseio.com"];
    // Write data to Firebase
    [[myRootRef childByAppendingPath:key] setValue:@{@"count":[NSNumber numberWithInteger:num]}];
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
