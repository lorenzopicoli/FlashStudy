//
//  FSAppDelegate.m
//  FlashStudy
//
//  Created by Lorenzo Piccoli on 01/10/13.
//  Copyright (c) 2013 LorenzoPiccoli. All rights reserved.
//

#import "FSAppDelegate.h"
#import "FSDatabase.h"
#import "Flurry.h"
#import "iRate.h"

@implementation FSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    database = [[FSDatabase alloc] init];
    [self setAppApperance];
    
    //Analytics
    
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"9S8MYRVP2WS29QKVTK3J"];
    
    //iRate
    
    [iRate sharedInstance].daysUntilPrompt = 5;
    [iRate sharedInstance].usesUntilPrompt = 10;
    [iRate sharedInstance].appStoreID = 761476004;
    
    return YES;
}

- (void)setAppApperance{
    
    //Nav Bar
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor whiteColor], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue" size:18.0], NSFontAttributeName, nil]];
    
    
    //Nav Bar Buttons
    shadow.shadowOffset = CGSizeMake(0, 0);
    [[UIBarButtonItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor], NSForegroundColorAttributeName,
      shadow, NSShadowAttributeName,
      [UIFont fontWithName:@"HelveticaNeue" size:15.0], NSFontAttributeName, nil]
                                                forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor], NSForegroundColorAttributeName,
      shadow, NSShadowAttributeName,
      [UIFont fontWithName:@"HelveticaNeue" size:15.0], NSFontAttributeName, nil]
                                                forState:UIControlStateHighlighted];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    //BackButton
//    UIImage *backButton = [[UIImage imageNamed:@"back_button_texture.png"]
//                           resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 5)];
    
//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
