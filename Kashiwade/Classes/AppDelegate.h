//
//  AppDelegate.h
//  Kashiwade
//
//  Created by LoopSessions on 2015/09/26.
//  Copyright (c) 2015年 LoopSessions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

//@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) ViewController *viewController;
@property (nonatomic, retain) UINavigationController *naviController;

@end
