//
//  AppDelegate.m
//  demo
//
//  Created by --- on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "CMClient.h"

#import "LoginViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc {
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //inittialize client library with default config
    [CMClient registerWithApple];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    UINavigationController* navController = [[[UINavigationController alloc] init] autorelease];
    LoginViewController* controller = [[[LoginViewController alloc] initWithNibName: @"LoginViewController" bundle:nil] autorelease];
    [navController pushViewController: controller animated: false];
    
    
    self.viewController = navController;
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    [CMClient storeDeviceToken: deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[CMClient sharedInstance] handleRemoteNotification: userInfo errorBlock:nil successBlock:nil];
}


@end
