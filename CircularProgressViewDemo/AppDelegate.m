//
//  AppDelegate.m
//  CircularProgressViewDemo
//
//  Created by nijino saki on 13-3-2.
//  Copyright (c) 2013年 nijino. All rights reserved.
//  QQ:20118368
//  http://nijino.cn

#import "AppDelegate.h"
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhoneStoryboard" bundle:nil];
    
    self.viewController = [storyboard instantiateInitialViewController];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    return YES;
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

@end
