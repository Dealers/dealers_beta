//
//  AppDelegate.m
//  GooglePlaces
//
//  Created by van Lint Jason on 28/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize storyboard;
@synthesize tabBarController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    int cacheSizeMemory = 4*1024*1024; // 4MB
    int cacheSizeDisk = 32*1024*1024; // 32MB
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:sharedCache];

    // Customizing the Navigation Bar:
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:150.0/255.0 green:0/255.0 blue:180.0/255.0 alpha:1.0]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"Navigation Bar Background"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage imageNamed:@"Navigation Bar Shade"]];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor colorWithRed:150.0/255.0 green:0.0/255.0 blue:180.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                          [UIFont fontWithName:@"Avenir-Roman" size:20.0], NSFontAttributeName, nil]];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    // Customizing the Tab Bar:
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:150.0/255.0 green:0/255.0 blue:180.0/255.0 alpha:1.0]];
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:150.0/255.0 green:0/255.0 blue:180.0/255.0 alpha:1.0]];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIFont fontWithName:@"Avenir-Roman" size:11.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    // Customizing other elements:
    [[UIPickerView appearance] setBackgroundColor: [UIColor groupTableViewBackgroundColor]];
    [[UIDatePicker appearance] setBackgroundColor: [UIColor groupTableViewBackgroundColor]];
    
    
    return YES;
}

- (void)setTabBarController
{
    storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    tabBarController = [[UITabBarController alloc]init];
    
    UINavigationController *navigationControllerFeed = [storyboard instantiateViewControllerWithIdentifier:@"feedNavController"];
    UINavigationController *navigationControllerExplore = [storyboard instantiateViewControllerWithIdentifier:@"exploreNavController"];
    UINavigationController *navigationControllerProfile = [storyboard instantiateViewControllerWithIdentifier:@"profileNavController"];
    UINavigationController *navigationControllerMore = [storyboard instantiateViewControllerWithIdentifier:@"moreNavController"];
    UIViewController *dummyViewController = [[UIViewController alloc]init]; // Just to create room for the Add Deal button in the middle of the tab bar.
    
    NSArray* controllers = [NSArray arrayWithObjects:navigationControllerFeed, navigationControllerExplore, dummyViewController, navigationControllerProfile, navigationControllerMore, nil];
    tabBarController.viewControllers = controllers;
    
    self.window.rootViewController = tabBarController;
    
    UITabBar *tabBar = tabBarController.tabBar;
    UITabBarItem *myFeed = [tabBar.items objectAtIndex:0];
    UITabBarItem *explore = [tabBar.items objectAtIndex:1];
    UITabBarItem *profile = [tabBar.items objectAtIndex:3];
    UITabBarItem *more = [tabBar.items objectAtIndex:4];
    
    myFeed.title = @"My Feed";
    myFeed.image = [UIImage imageNamed:@"My Feed Tab"];
    myFeed.selectedImage = [UIImage imageNamed:@"My Feed Tab Selected"];
    explore.title = @"Explore";
    explore.image = [UIImage imageNamed:@"Explore Tab"];
    explore.selectedImage = [UIImage imageNamed:@"Explore Tab Selected"];
    explore.titlePositionAdjustment = UIOffsetMake(-6, 0);
    profile.title = @"Profile";
    profile.image = [UIImage imageNamed:@"Profile Tab"];
    profile.selectedImage = [UIImage imageNamed:@"Profile Tab Selected"];
    profile.titlePositionAdjustment = UIOffsetMake(6, 0);
    more.title = @"More";
    more.image = [UIImage imageNamed:@"More Tab"];
    more.selectedImage = [UIImage imageNamed:@"More Tab Selected"];
    
    // Adding the Add Deal button to the UITabBarController:
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(tabBarController.tabBar.center.x-30.5,tabBarController.tabBar.center.y-30.5, 61, 61);
    [button setImage:[UIImage imageNamed:@"Add Deal"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"Add Deal Highlighted"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(addDealVC:) forControlEvents:UIControlEventTouchUpInside];
    button.userInteractionEnabled = YES;
    [tabBarController.view addSubview:button];
}

- (void)addDealVC: (id) sender {
    UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"addDealNavController"];
    [tabBarController presentViewController:navigationController animated:YES completion:nil];
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
    /*_Animate_first= [[NSString alloc]init];
    _Animate_first= [[NSString alloc]init];
    _UserID = [[NSString alloc]init];
    _AfterAddDeal = [[NSString alloc]init];
    _onlineOrLocal = [[NSString alloc]init];*/
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}
@end
