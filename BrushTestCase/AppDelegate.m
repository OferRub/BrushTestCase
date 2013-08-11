//
//  AppDelegate.m
//  PhotoCollage
//
//  Created by Ofer Rubinstein on 6/27/13.
//  Copyright (c) 2013 Ofer Rubinstein. All rights reserved.
//

#import "AppDelegate.h"
#import <Dropico/Dropico.h>
//#define FB_APP_ID               @"521529197884329"

#import "ViewController.h"

@implementation AppDelegate
{
    ViewController        *lastView;
    UIApplication * lastApp;
    UIBackgroundTaskIdentifier lastTask;
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  
    [[UIApplication sharedApplication] setStatusBarHidden: YES withAnimation:UIStatusBarAnimationNone];
    [self setWindow:[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    
    self.viewController = [[ViewController alloc] init];
    
    [self.window setRootViewController:self.viewController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"Background");
    //    lastView = [[AppManager sharedAppManager] mainView];
    lastApp = application;
    //    UIBackgroundTaskIdentifier task = [application beginBackgroundTaskWithExpirationHandler: ^(void){
    [[DMGraphics manager] pause];
    //        [lastApp endBackgroundTask:lastTask];
    //    }];
    //    lastTask = task;
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
    [[DMGraphics manager] resume];
    
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // [[DMGraphics manager] resume];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // [[DMGraphics manager] pause];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
