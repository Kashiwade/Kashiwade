//
//  KashiwadeDB.h
//  Kashiwade
//
//  Created by gotojo on 2015/10/11.
//  Copyright © 2015年 LoopSessions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KashiwadeDB : NSObject

+ (int)getNum:(NSString*)key;
+ (int)incNum:(NSString*)key;

@end
