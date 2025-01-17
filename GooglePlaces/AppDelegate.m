//
//  AppDelegate.m
//  GooglePlaces
//
//  Created by van Lint Jason on 28/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//itzik
//itzikb

#import "AppDelegate.h"
#import <AWSS3/AWSS3.h>
#import <AWSCore/AWSCore.h>
#import <Intercom/Intercom.h>
#import "DealersTabBarController.h"
#import "DealsTableViewController.h"
#import "ViewDealViewController.h"
#import "ActivityTableViewController.h"
#import "KeychainItemWrapper.h"
#import "PushNotificationView.h"
#import "Branch.h"
#import "GAI.h"

#define AWS_ACCESS_KEY_ID @"AKIAIWJFJX72FWKD2LYQ"
#define AWS_SECRET_ACCESS_KEY @"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"
#define AWS_S3_BUCKET_NAME @"dealers-app"
#define S3_PHOTOS_ADDRESS @"https://s3-eu-west-1.amazonaws.com/dealers-app/"

@interface AppDelegate() {
    
    DealersTabBarController *tabBarController;
}

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize storyboard;

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([[Branch getInstance] handleDeepLink:url]) {
        return YES;
    }
    
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    int cacheSizeMemory = 4*1024*1024; // 4MB
    int cacheSizeDisk = 32*1024*1024; // 32MB
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:sharedCache];
    
    // Checking if launched with push notificaiton
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        NSLog(@"Application opened with a remote notification.");
    }
    
    // Customizing the Navigation Bar:
    UIImage *imageNavBar = [UIImage imageNamed:@"Navigation Bar Background"];
    imageNavBar = [imageNavBar stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:150.0/255.0 green:0/255.0 blue:180.0/255.0 alpha:1.0]];
    [[UINavigationBar appearance] setBackgroundImage:imageNavBar forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage imageNamed:@"Navigation Bar Shade"]];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor colorWithRed:150.0/255.0 green:0.0/255.0 blue:180.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                          [UIFont fontWithName:@"Avenir-Roman" size:20.0], NSFontAttributeName, nil]];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    // Customizing other elements:
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:150.0/255.0 green:0/255.0 blue:180.0/255.0 alpha:1.0]];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIFont fontWithName:@"Avenir-Roman" size:11.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [[UIPageControl appearanceWhenContainedIn:[UIPageViewController class], nil] setPageIndicatorTintColor:[UIColor colorWithWhite:0.85 alpha:1.0]];
    [[UIPageControl appearanceWhenContainedIn:[UIPageViewController class], nil] setCurrentPageIndicatorTintColor:[UIColor blackColor]];
    
    // Configuring RestKit:
    [self configureRestKit];
    
    // Configuting Amazon Web Service SDK:
    AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:AWS_ACCESS_KEY_ID
                                                                                                     secretKey:AWS_SECRET_ACCESS_KEY];
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionEUWest1
                                                                          credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    
    // For showing the network activity indicator whenever communicating with the web:
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // For printing in the log info about the outputs and inputs via RestKit:
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    
    // Adding a window for the remote notifications
    self.pushNotificationsWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 64.0)];
    
    self.pushNotificationsWindow.backgroundColor = [UIColor clearColor];
    self.pushNotificationsWindow.windowLevel = UIWindowLevelStatusBar + 1;
    self.pushNotificationsWindow.hidden = YES;
    
    // Initializing Branch Metrics's SDK
    Branch *branch = [Branch getInstance];
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        // params are the deep linked params associated with the link that the user clicked before showing up.
        if (!error) {
            if (params.count > 0) {
                [self presentContentWithParams:params];
            }
        } else {
            NSLog(@"There was an error with Branch: %@", error.localizedDescription);
        }
    }];
    
    // Initializing the Google Analytics tracker
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-62425106-1"];
    
    // Initialize Intercom
    [Intercom setApiKey:@"ios_sdk-883445c2173ecd332b3f61c6c62b8496e888c48b" forAppId:@"z1b3ijln"];
    
    return YES;
}


#pragma mark - Device

- (void)configureDeviceManager
{
    self.updateDeviceManager = [[RKObjectManager alloc] initWithHTTPClient:[RKObjectManager sharedManager].HTTPClient];
    
    self.updateDeviceManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    RKObjectMapping *updateDeviceMapping = [RKObjectMapping mappingForClass:[Device class]];
    [updateDeviceMapping addAttributeMappingsFromDictionary: @{
                                                               @"dealer" : @"dealerID",
                                                               @"token" : @"token",
                                                               @"last_update_date" : @"lastUpdateDate"
                                                               }];
    
    RKResponseDescriptor *updateDeviceResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:updateDeviceMapping
                                                 method:RKRequestMethodAny
                                            pathPattern:nil
                                                keyPath:nil
                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKRequestDescriptor *updateDeviceRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:[updateDeviceMapping inverseMapping]
                                          objectClass:[Device class]
                                          rootKeyPath:nil
                                               method:RKRequestMethodAny];
    
    RKResponseDescriptor *errorResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self errorMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:nil
                                                keyPath:nil
                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    
    [self.updateDeviceManager addResponseDescriptorsFromArray:@[updateDeviceResponseDescriptor, errorResponseDescriptor]];
    [self.updateDeviceManager addRequestDescriptor:updateDeviceRequestDescriptor];
}

- (void)instantiateDeviceWithToken:(NSString *)token
{
    if (!self.device) {
        self.device = [[Device alloc] init];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"deviceID"]) {
        // Signed in - no details on device. Get them and save
        self.device.token = token;
        [self checkIfDeviceExists];
        
    } else {
        self.device.deviceID = [defaults objectForKey:@"deviceID"];
        self.device.UDID = [defaults objectForKey:@"UDID"];
        self.device.os = [defaults objectForKey:@"deviceOS"];
        self.device.creationDate = [defaults objectForKey:@"deviceCreationDate"];
        self.device.badge = [NSNumber numberWithInteger:[UIApplication sharedApplication].applicationIconBadgeNumber];
        self.device.token = token;
        [self updateDeviceWithDealer];
    }
}

- (void)checkIfDeviceExists
{
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/devices/"
                                           parameters:@{@"token" : self.device.token}
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  if (mappingResult.array.count > 0) {
                                                      self.device = mappingResult.firstObject;
                                                      [self saveDeviceDetails];
                                                      [self updateDeviceWithDealer];
                                                  } else {
                                                      self.device.UDID = [[UIDevice currentDevice] identifierForVendor].UUIDString;
                                                      self.device.os = @"Ios";
                                                      self.device.creationDate = [NSDate date];
                                                      self.device.badge = [NSNumber numberWithInteger:0];
                                                      [self postDevice];
                                                  }
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  
                                                  NSLog(@"Notification's deal failed to download.");
                                              }];
}

- (void)postDevice
{
    [[RKObjectManager sharedManager] postObject:self.device
                                           path:@"/devices/"
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            
                                            NSLog(@"Device posted successfully!");
                                            self.device = mappingResult.firstObject;
                                            [self saveDeviceDetails];
                                            [self updateDeviceWithDealer];
                                            timesTriedToPostDevice = 0;
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            
                                            NSLog(@"Failed to post the device.");
                                            
                                            // Try again
                                            if (timesTriedToPostDevice < 2) {
                                                timesTriedToPostDevice++;
                                                [self postDevice];
                                            } else {
                                                timesTriedToPostDevice = 0;
                                            }
                                        }];
}

- (void)saveDeviceDetails
{
    if (self.device) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.device.deviceID forKey:@"deviceID"];
        [defaults setObject:self.device.UDID forKey:@"UDID"];
        [defaults setObject:self.device.os forKey:@"deviceOS"];
        [defaults setObject:self.device.creationDate forKey:@"deviceCreationDate"];
    } else {
        NSLog(@"Something's wrong. Attempting to save device to memory but there's no device");
    }
}

- (void)updateDeviceWithDealer
{
    self.device.dealerID = self.dealer.dealerID;
    self.device.lastUpdateDate = [NSDate date];
    [self patchDeviceFor:@"deviceUpdate"];
}

- (void)updateDeviceAfterLogOut
{
    self.device.dealerID = nil;
    [self patchDeviceFor:@"deviceUpdate"];
}

- (void)patchDeviceFor:(NSString *)purpose
{
    NSString *path = [NSString stringWithFormat:@"/devices/%@/", self.device.deviceID];
    
    if ([purpose isEqualToString:@"deviceUpdate"]) {
        
        if (!self.updateDeviceManager) {
            [self configureDeviceManager];
        }
        
        [self.updateDeviceManager patchObject:self.device
                                         path:path
                                   parameters:nil
                                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                          
                                          NSLog(@"Device was updated with token successfully..");
                                          
                                          self.device = mappingResult.firstObject;
                                          
                                          timesTriedToUpdateDevice = 0;
                                      }
                                      failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                          
                                          NSLog(@"Failed to update device with token...");
                                          
                                          //check if device wasn't found. If so post it.
                                          
                                          Error *errors = [[[error userInfo] objectForKey:RKObjectMapperErrorObjectsKey] lastObject];
                                          
                                          if ([[errors messagesString] isEqualToString:NSLocalizedString(@"Not found", nil)]) {
                                              
                                              // Post device
                                              [self postDevice];
                                              
                                          } else {
                                              
                                              // Something's wrong. Try again
                                              if (timesTriedToUpdateDevice < 2) {
                                                  timesTriedToUpdateDevice++;
                                                  [self patchDeviceFor:purpose];
                                              } else {
                                                  timesTriedToUpdateDevice = 0;
                                              }
                                          }
                                      }];
        
    } else if ([purpose isEqualToString:@"badgeReset"]) {
        
        [[RKObjectManager sharedManager] patchObject:self.device
                                                path:path
                                          parameters:nil
                                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                 
                                                 NSLog(@"Device badge reseted successfully..");
                                                 
                                                 self.device = mappingResult.firstObject;
                                                 
                                                 timesTriedToUpdateDevice = 0;
                                             }
                                             failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                 
                                                 NSLog(@"Failed to reset device badge...");
                                                 
                                                 // Try again
                                                 if (timesTriedToUpdateDevice < 2) {
                                                     timesTriedToUpdateDevice++;
                                                     [self patchDeviceFor:purpose];
                                                 } else {
                                                     timesTriedToUpdateDevice = 0;
                                                 }
                                             }];
    }
}

- (void)resetBadgeCounter
{
    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
        
        self.device.badge = [NSNumber numberWithInteger:0];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        UITabBarItem *activityItem = [tabBarController.tabBar.items objectAtIndex:4];
        activityItem.badgeValue = nil;
        [self patchDeviceFor:@"badgeReset"];
    }
}


#pragma mark - Tab Bar Controller

- (void)setTabBarController
{
    storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    tabBarController = [[DealersTabBarController alloc] init];
    
    UINavigationController *navigationControllerFeed = [storyboard instantiateViewControllerWithIdentifier:@"feedNavController"];
    UINavigationController *navigationControllerExplore = [storyboard instantiateViewControllerWithIdentifier:@"exploreNavController"];
    UINavigationController *navigationControllerProfile = [storyboard instantiateViewControllerWithIdentifier:@"profileNavController"];
    UINavigationController *navigationControllerMore = [storyboard instantiateViewControllerWithIdentifier:@"activityNavController"];
    UIViewController *dummyViewController = [[UIViewController alloc] init]; // Just to create room for the Add Deal button in the middle of the tab bar.
    
    NSArray* controllers = [NSArray arrayWithObjects:navigationControllerFeed, navigationControllerExplore, dummyViewController, navigationControllerProfile, navigationControllerMore, nil];
    tabBarController.viewControllers = controllers;
    
    self.window.rootViewController = tabBarController;
    
    UITabBar *tabBar = tabBarController.tabBar;
    UITabBarItem *myFeed = [tabBar.items objectAtIndex:0];
    UITabBarItem *explore = [tabBar.items objectAtIndex:1];
    UITabBarItem *profile = [tabBar.items objectAtIndex:3];
    UITabBarItem *activity = [tabBar.items objectAtIndex:4];
    
    myFeed.title = NSLocalizedString(@"My Feed", nil);
    myFeed.image = [UIImage imageNamed:@"My Feed Tab"];
    myFeed.selectedImage = [UIImage imageNamed:@"My Feed Tab Selected"];
    explore.title = NSLocalizedString(@"Explore", nil);
    explore.image = [UIImage imageNamed:@"Explore Tab"];
    explore.selectedImage = [UIImage imageNamed:@"Explore Tab Selected"];
    explore.titlePositionAdjustment = UIOffsetMake(-6, 0);
    profile.title = NSLocalizedString(@"Profile", nil);
    profile.image = [UIImage imageNamed:@"Profile Tab"];
    profile.selectedImage = [UIImage imageNamed:@"Profile Tab Selected"];
    profile.titlePositionAdjustment = UIOffsetMake(6, 0);
    activity.title = NSLocalizedString(@"Activity", nil);;
    activity.image = [UIImage imageNamed:@"Activity Tab"];
    activity.selectedImage = [UIImage imageNamed:@"Activity Tab Selected"];
    
    // Register for push notifications
    UIApplication *application = [UIApplication sharedApplication];
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [application registerUserNotificationSettings:mySettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    } else {
        
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    
    // Identifying the user for the Branch analytics
    [[Branch getInstance] setIdentity:self.dealer.dealerID.stringValue];
    
    // Is there a shared content that's waiting for the tab bar controller?
    if (pendingContent) {
        [self presentContentWithParams:pendingContent];
        pendingContent = nil;
    }
    
    // Is there a remote notifiaction that's waiting for the tab bar controller?
    if (pendingNotification) {
        [self presentNotificationOfType:pendingNotification];
        pendingNotification = nil;
    }
}

- (void)removeTabBar
{
    if (tabBarController) {
        tabBarController = nil;
    }
}

- (void)hidePlusButton
{
    UIButton *plusButton = (UIButton *)[tabBarController.view viewWithTag:123];
    [UIView animateWithDuration:0.3
                     animations:^{
                         plusButton.alpha = 0; }];
}

- (void)showPlusButton
{
    UIButton *plusButton = (UIButton *)[tabBarController.view viewWithTag:123];
    [UIView animateWithDuration:0.52
                     animations:^{
                         plusButton.alpha = 1.0; }
                     completion:^(BOOL finished){
                         [tabBarController.view bringSubviewToFront:plusButton];
                     }];
}


#pragma mark - Push notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"Successfully Registered for Remote Notifications with Device Token %@", deviceToken);
    
    NSString  *tokenString = [[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
                              stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    
    [self instantiateDeviceWithToken:tokenString];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to Register for Remote Notifications.");
    NSLog(@"%@, %@", error, error.localizedDescription);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:error.localizedDescription
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    UIApplicationState state = application.applicationState;
    userInfoForActive = userInfo;

    if (state == UIApplicationStateActive) {
        
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber - 1;
        NSString *type = userInfoForActive[@"type"];
        
        if ([type isEqualToString:@"New Rank"]) {
            if (userInfoForActive[@"rank"] && tabBarController) {
                if (self.addDealState) {
                    pendingNewRankAnnouncement = userInfoForActive[@"rank"];
                } else {
                    [self presentNewRank:userInfoForActive[@"rank"]];
                    pendingNewRankAnnouncement = nil;
                }
            }
        
        } else if ([type isEqualToString:@"Weekly Deals"]) {
            weeklyDealsID = userInfoForActive[@"weekly_deals_id"];
            [self notificationWhenActive:type];
            return;
            
        } else {
            // It's a deal - download it
            pushedDealID = userInfoForActive[@"deal"];
            notifyingDealerID = userInfoForActive[@"dealer"];
            if (pushedDealID) {
                NSString *path = [NSString stringWithFormat:@"/alldeals/%@/", pushedDealID];
                [[RKObjectManager sharedManager] getObjectsAtPath:path
                                                       parameters:nil
                                                          success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                              
                                                              NSLog(@"Notification's deal downloaded successfully!");
                                                              self.pushedDeal = mappingResult.firstObject;
                                                              
                                                              // download the notifying dealer
                                                              if (notifyingDealerID) {
                                                                  [self downloadNotifyingDealer];
                                                              }
                                                          }
                                                          failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                              
                                                              NSLog(@"Notification's deal failed to download.");
                                                              completionHandler(UIBackgroundFetchResultFailed);
                                                          }];
            }
        }
        
        completionHandler(UIBackgroundFetchResultNoData);
        
    } else  if (state == UIApplicationStateBackground) {
        
        // Download the object, wheather it is a deal, dealer, else...
        
        if (userInfoForActive[@"deal"]) {
            // There is a deal object. Download it.
            NSString *path = [NSString stringWithFormat:@"/alldeals/%@/", userInfo[@"deal"]];
            [[RKObjectManager sharedManager] getObjectsAtPath:path
                                                   parameters:nil
                                                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                          
                                                          NSLog(@"Deal downloaded in background successfully.");
                                                          self.pushedDeal = mappingResult.firstObject;
                                                          completionHandler(UIBackgroundFetchResultNewData);
                                                      }
                                                      failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                          
                                                          NSLog(@"Deal failed to download in background.");
                                                          completionHandler(UIBackgroundFetchResultFailed);
                                                      }];
        }
        
    } else if (state == UIApplicationStateInactive) {
        
        NSString *type = userInfoForActive[@"type"];
        
        // App was launched with push notificaiton
        if ([type isEqualToString:@"New Rank"]) {
            if (userInfoForActive[@"rank"]) {
                [self logPSEvent:@"new_rank"];
                cashedRank = userInfoForActive[@"rank"];
                [self presentNotificationOfType:@"newRank"];
            }
        } else if ([type isEqualToString:@"Weekly Deals"]) {
            if (userInfoForActive[@"weekly_deals_id"]) {
                [self logPSEvent:@"weekly_deals"];
                weeklyDealsID = userInfoForActive[@"weekly_deals_id"];
                [self presentNotificationOfType:@"dealsList"];
            }
        } else {
            if (userInfoForActive[@"deal"]) {
                [self logPSEvent:@"deal_notification"];
                pushedDealID = userInfoForActive[@"deal"];
                [self presentNotificationOfType:@"deal"];
            }
        }
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

- (void)downloadNotifyingDealer
{
    NSString *path = [NSString stringWithFormat:@"/dealers/%@/", notifyingDealerID];
    [[RKObjectManager sharedManager] getObjectsAtPath:path
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  NSLog(@"Notifying dealer downloaded successfully!");
                                                  self.notifyingDealer = mappingResult.firstObject;
                                                  
                                                  // download the dealer's photo
                                                  [self otherProfilePic:self.notifyingDealer forTarget:nil notificationName:@"Push Notifications" atIndexPath:nil];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  
                                                  NSLog(@"Notifying dealer failed to download.");
                                              }];
}

- (void)presentContentWithParams:(NSDictionary *)params
{
    if (params[@"deal"]) {
        
        if (!tabBarController) {
            pendingContent = params;
            return;
        }
        
        UINavigationController *navigationController = [[tabBarController viewControllers] objectAtIndex:0];
        [tabBarController setSelectedIndex:0];
        ViewDealViewController *vdvc = [storyboard instantiateViewControllerWithIdentifier:@"ViewDealID"];
        vdvc.dealID = params[@"deal"];
        [navigationController pushViewController:vdvc animated:YES];
    }
}

- (void)presentNotificationOfType:(NSString *)type
{
    if (!tabBarController) {
        pendingNotification = type;
        return;
    }
    
    NSString *pushNotificationType = userInfoForActive[@"type"];
    UINavigationController *navigationController;
    if ([pushNotificationType isEqualToString:@"Category Deals"]) {
        navigationController = [[tabBarController viewControllers] objectAtIndex:0];
        [tabBarController setSelectedIndex:0];
    } else {
        navigationController = [[tabBarController viewControllers] objectAtIndex:4];
        [tabBarController setSelectedIndex:4];
        ActivityTableViewController *atvc = [[navigationController viewControllers] firstObject];
        [atvc refresh];
    }
    
    if ([type isEqualToString:@"deal"]) {
        ViewDealViewController *vdvc = [storyboard instantiateViewControllerWithIdentifier:@"ViewDealID"];
        if ([self.pushedDeal.dealID isEqualToValue:pushedDealID]) {
            vdvc.deal = self.pushedDeal;
        } else {
            vdvc.dealID = pushedDealID;
        }
        [navigationController pushViewController:vdvc animated:YES];
        [self resetBadgeCounter];
        pushedDealID = nil;
        
    } else if ([type isEqualToString:@"dealsList"]) {
        DealsTableViewController *dtvc = [self.storyboard instantiateViewControllerWithIdentifier:@"DealsID"];
        dtvc.weeklyDealsID = weeklyDealsID;
        dtvc.recommendedDealsTitle = userInfoForActive[@"subject_title"];
        [navigationController pushViewController:dtvc animated:YES];
        [self resetBadgeCounter];
        weeklyDealsID = nil;
    
    } else if([type isEqualToString:@"newRank"]) {
        NewRankViewController *nrvc = [self.storyboard instantiateViewControllerWithIdentifier:@"NewRank"];
        nrvc.rank = cashedRank;
        [navigationController pushViewController:nrvc animated:YES];
        [self resetBadgeCounter];
    }
    
    userInfoForActive = nil;
}

- (void)notificationWhenActive:(NSString *)type
{
    if (!tabBarController) {
        NSLog(@"There's a problem - no tab bar controller even though user is active.");
        return;
    }
    
    PushNotificationView *pushNotificationView = [[PushNotificationView alloc] initWithDelegate:self.pushNotificationsWindow];
    [pushNotificationView layoutSubviews];

    if ([type isEqualToString:@"Weekly Deals"]) {
        pushNotificationView.notificationPhoto.image = [UIImage imageNamed:@"Weekly Deals Notification Icon"];
        pushNotificationView.message.text = userInfoForActive[@"aps"][@"alert"];
        pushNotificationView.objectID = weeklyDealsID;
    
    } else {
        if (self.notifyingDealer.photo) {
            pushNotificationView.notificationPhoto.image = [UIImage imageWithData:self.notifyingDealer.photo];
        } else {
            pushNotificationView.notificationPhoto.image = [UIImage imageNamed:@"Dealers Icon"];
        }
        pushNotificationView.message.text = userInfoForActive[@"aps"][@"alert"];
        pushNotificationView.deal = self.pushedDeal;
    }
    
    [pushNotificationView presentNotification];
}

- (void)exitAddDealState
{
    if (pendingNewRankAnnouncement) {
        [self presentNewRank:pendingNewRankAnnouncement];
    }
    
    self.addDealState = NO;
    pendingNewRankAnnouncement = nil;
}

- (void)presentNewRank:(NSString *)rank
{
    if (rank) {
        NewRankViewController *nrvc = [self.storyboard instantiateViewControllerWithIdentifier:@"NewRank"];
        nrvc.navControllerDelegate = (UINavigationController *)tabBarController.selectedViewController;
        self.dealer.rank = rank;
        nrvc.rank = rank;
        [nrvc.navControllerDelegate presentViewController:nrvc animated:YES completion:nil];
    }
}


#pragma mark - Helper Methods

- (void)saveUserDetailsOnDevice
{
    if (tabBarController) { // In order to prevent the save if the user is not logged in.
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setObject:self.dealer.dealerID forKey:@"dealerID"];
        [defaults setObject:self.dealer.email forKey:@"email"];
        [defaults setObject:self.dealer.username forKey:@"username"];
        [defaults setObject:self.dealer.fullName forKey:@"fullName"];
        [defaults setObject:self.dealer.dateOfBirth forKey:@"dateOfBirth"];
        [defaults setObject:self.dealer.gender forKey:@"gender"];
        [defaults setObject:self.dealer.registerDate forKey:@"registerDate"];
        [defaults setObject:self.dealer.location forKey:@"location"];
        [defaults setObject:self.dealer.about forKey:@"about"];
        [defaults setObject:self.dealer.photoURL forKey:@"photoURL"];
        [defaults setObject:self.dealer.uploadedDeals forKey:@"uploadedDeals"];
        [defaults setObject:self.dealer.likedDeals forKey:@"likedDeals"];
        [defaults setObject:self.dealer.sharedDeals forKey:@"sharedDeals"];
        [defaults setObject:self.dealer.followedBy forKey:@"followedBy"];
        [defaults setObject:self.dealer.followings forKey:@"followings"];
        [defaults setObject:self.dealer.badReportsCounter forKey:@"badReportsCounter"];
        [defaults setObject:self.dealer.score forKey:@"score"];
        [defaults setObject:self.dealer.rank forKey:@"rank"];
        [defaults setObject:self.dealer.reliability forKey:@"reliability"];
        [defaults setObject:self.dealer.facebookPseudoUserID forKey:@"facebookPseudoUserID"];
        [defaults setObject:self.dealer.invitationCounter forKey:@"invitationCounter"];
        [self saveScreenCountersOnDevice];

        [defaults synchronize];
        
        if (self.dealer.photoURL.length > 1 && ![self.dealer.photoURL isEqualToString:@"None"]) {
            [self saveProfilePic:self.dealer.photo];
        }
    }
}

- (void)saveScreenCountersOnDevice
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:self.dealer.screenCounters.screenCountersID forKey:@"screenCountersID"];
    [defaults setObject:self.dealer.screenCounters.myFeed forKey:@"myFeedCounter"];
    [defaults setObject:self.dealer.screenCounters.explore forKey:@"exploreCounter"];
    [defaults setObject:self.dealer.screenCounters.activity forKey:@"activityCounter"];
    [defaults setObject:self.dealer.screenCounters.profile forKey:@"profileCounter"];
    [defaults setObject:self.dealer.screenCounters.whereIsTheDealLocal forKey:@"whereIsTheDealLocalCounter"];
    [defaults setObject:self.dealer.screenCounters.whereIsTheDealOnline forKey:@"whereIsTheDealOnlineCounter"];
    [defaults setObject:self.dealer.screenCounters.whatIsTheDealLocal forKey:@"whatIsTheDealLocalCounter"];
    [defaults setObject:self.dealer.screenCounters.whatIsTheDealOnline forKey:@"whatIsTheDealOnlineCounter"];
    [defaults setObject:self.dealer.screenCounters.haveMoreDetails forKey:@"haveMoreDetailsCounter"];
    [defaults setObject:self.dealer.screenCounters.viewDeal forKey:@"viewDealCounter"];
    
    [defaults synchronize];
}

- (void)removeUserDetailsFromDevice
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults removeObjectForKey:@"dealerID"];
    [defaults removeObjectForKey:@"email"];
    [defaults removeObjectForKey:@"username"];
    [defaults removeObjectForKey:@"fullName"];
    [defaults removeObjectForKey:@"dateOfBirth"];
    [defaults removeObjectForKey:@"gender"];
    [defaults removeObjectForKey:@"registerDate"];
    [defaults removeObjectForKey:@"location"];
    [defaults removeObjectForKey:@"about"];
    [defaults removeObjectForKey:@"photoURL"];
    [defaults removeObjectForKey:@"uploadedDeals"];
    [defaults removeObjectForKey:@"likedDeals"];
    [defaults removeObjectForKey:@"sharedDeals"];
    [defaults removeObjectForKey:@"followedBy"];
    [defaults removeObjectForKey:@"followings"];
    [defaults removeObjectForKey:@"badReportsCounter"];
    [defaults removeObjectForKey:@"score"];
    [defaults removeObjectForKey:@"rank"];
    [defaults removeObjectForKey:@"reliability"];
    [defaults removeObjectForKey:@"facebookPseudoUserID"];
    [defaults removeObjectForKey:@"invitationCounter"];
    [defaults removeObjectForKey:@"screenCountersID"];
    [defaults removeObjectForKey:@"myFeedCounter"];
    [defaults removeObjectForKey:@"exploreCounter"];
    [defaults removeObjectForKey:@"activityCounter"];
    [defaults removeObjectForKey:@"whereIsTheDealLocalCounter"];
    [defaults removeObjectForKey:@"whereIsTheDealOnlineCounter"];
    [defaults removeObjectForKey:@"whatIsTheDealLocalCounter"];
    [defaults removeObjectForKey:@"whatIsTheDealOnlineCounter"];
    [defaults removeObjectForKey:@"haveMoreDetailsCounter"];
    [defaults removeObjectForKey:@"viewDealCounter"];
    [defaults removeObjectForKey:@"authorized"];
    
    [defaults synchronize];
    
    [self removeProfilePic];
    
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"DealersKeychain" accessGroup:nil];
    [keychain resetKeychainItem];
}

- (void)removeDeviceDetailsFromDevice
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"deviceID"];
    [defaults removeObjectForKey:@"UDID"];
    [defaults removeObjectForKey:@"deviceOS"];
    [defaults removeObjectForKey:@"deviceCreationDate"];
    [defaults synchronize];
}

- (void)saveProfilePic:(NSData *)image
{
    if (image != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"profile_pic_%@.jpg", self.dealer.username]];
        [image writeToFile:path atomically:YES];
    }
}

- (NSData *)loadProfilePic
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"profile_pic_%@.jpg", self.dealer.username]];
    NSData *profilePic = [NSData dataWithContentsOfFile:path];
    
    return profilePic;
}

- (void)removeProfilePic
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"profile_pic_%@.jpg", self.dealer.username]];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        NSLog(@"Profile photo successfuly removed");
    }
    else {
        NSLog(@"Could not delete file - %@. Error:\n%@ \n%@ \n%@ \n%@ ", filePath, [error localizedDescription], [error localizedFailureReason],[error localizedRecoveryOptions],[error localizedRecoverySuggestion]);
    }
}

- (void)updateUserInfo
{
    NSString *path = [NSString stringWithFormat:@"/dealers/%@/", self.dealer.dealerID];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:path
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  NSLog(@"Dealer updated successfuly...");
                                                  self.dealer = mappingResult.firstObject;
                                                  [self saveUserDetailsOnDevice];
                                                  
                                                  self.dealer.photo = [self loadProfilePic];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  
                                                  NSLog(@"Dealer couldn't be updated...");
                                              }];
}

- (UIImage *)myProfilePic
{
    if (self.dealer.photo) {
        
        return [UIImage imageWithData:self.dealer.photo];
        
    } else {
        
        return [UIImage imageNamed:@"Profile Pic Placeholder"];
    }
}

- (void)otherProfilePic:(Dealer *)dealer forTarget:(NSString *)target notificationName:(NSString *)notificationName atIndexPath:(NSIndexPath *)indexPath
{
    if (dealer.photoURL.length > 1 && ![dealer.photoURL isEqualToString:@"None"]) {
        
        AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
        
        NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:
                                         [NSString stringWithFormat:@"profile_pic_tmp_%@_%@.jpg", target, dealer.dealerID]];
        
        NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
        
        AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
        
        downloadRequest.bucket = AWS_S3_BUCKET_NAME;
        downloadRequest.key = dealer.photoURL;
        downloadRequest.downloadingFileURL = downloadingFileURL;
        
        [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
            
            if (task.error) {
                if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                    switch (task.error.code) {
                        case AWSS3TransferManagerErrorCancelled:
                        case AWSS3TransferManagerErrorPaused:
                            break;
                            
                        default:
                            NSLog(@"Error: %@", task.error);
                            return nil;
                            break;
                    }
                } else {
                    // Unknown error.
                    NSLog(@"Error: %@", task.error);
                    
                }
            }
            
            if (task.result) {
                
                dealer.photo = [NSData dataWithContentsOfFile:downloadingFilePath];
                dealer.downloadingPhoto = NO;
                
                if ([notificationName isEqualToString:@"Push Notifications"]) {
                    [self notificationWhenActive:@"Deal"];
                    return nil;
                }
                __block UIImage *image = [UIImage imageWithData:dealer.photo];
                __block NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                  image, @"image",
                                                  notificationName, @"notificationName",
                                                  target, @"target",
                                                  indexPath, @"indexPath",
                                                  nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                                    object:nil
                                                                  userInfo:userInfo];
            }
            
            return nil;
        }];
        
    } else {
        
        dealer.photo = UIImageJPEGRepresentation([UIImage imageNamed:@"Profile Pic Placeholder"], 1.0);
        dealer.downloadingPhoto = NO;
        NSDictionary *userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:
                                  [UIImage imageNamed:@"Profile Pic Placeholder"], @"image",
                                  notificationName, @"notificationName",
                                  target, @"target",
                                  indexPath, @"indexPath",
                                  nil];
        // We need to delay the post of the notification so the cell will have sufficient time to be created.
        [self performSelector:@selector(sendNotificationAfterDelay:) withObject:userInfo afterDelay:0.1];
    }
}

- (void)sendNotificationAfterDelay:(NSDictionary *)userInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:[userInfo objectForKey:@"notificationName"]
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)downloadPhotosForDeal:(Deal *)deal notificationName:(NSString *)notificationName atIndexPath:(NSIndexPath *)indexPath mode:(NSString *)mode
{
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:
                                     [NSString stringWithFormat:@"deal_photo_tmp_%@.jpg", deal.dealID]];
    
    NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
    
    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    
    downloadRequest.bucket = AWS_S3_BUCKET_NAME;
    downloadRequest.key = deal.photoURL1;
    downloadRequest.downloadingFileURL = downloadingFileURL;
    
    [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
        
        if (task.error) {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                        break;
                        
                    default:
                        NSLog(@"Error: %@", task.error);
                        return nil;
                        break;
                }
            } else {
                // Unknown error.
                NSLog(@"Error: %@", task.error);
            }
        }
        
        if (task.result) {
            
            deal.photo1 = [UIImage imageWithContentsOfFile:downloadingFilePath];
            deal.downloadingPhoto = NO;
            
            __block NSDictionary *userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:
                                              deal.photo1, @"image",
                                              indexPath, @"indexPath",
                                              mode, @"mode",
                                              nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                                object:nil
                                                              userInfo:userInfo];
        }
        
        return nil;
    }];
}

- (void)sendNotificationOfType:(NSString *)type toRecipients:(NSArray *)recipients regardingTheDeal:(NSNumber *)dealID
{
    Notification *notification = [[Notification alloc]initWithType:type
                                                        recipients:recipients
                                                            dealer:self.dealer
                                                              deal:dealID
                                                              date:[NSDate date]];
    
    if ([recipients containsObject:self.dealer.dealerID]) {
        NSMutableArray *recipientsMutable = [[NSMutableArray alloc] initWithArray:recipients];
        [recipientsMutable removeObject:self.dealer.dealerID];
        recipients = recipientsMutable;
    }
    
    if (recipients.count > 0) {
        
        [[RKObjectManager sharedManager] postObject:notification
                                               path:@"/addnotifications/"
                                         parameters:nil
                                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                
                                                NSLog(@"Notification sent successfully!");
                                            }
                                            failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                
                                                NSLog(@"Notification failed to be sent...");
                                            }];
    }
}

- (BOOL)didDealExpired:(Deal *)deal
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *todaysComponents = [calendar components:NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
    NSDate *today = [calendar dateFromComponents:todaysComponents];
    
    if ([today compare:deal.expiration] == NSOrderedDescending) {
        return YES;
    } else {
        return NO;
    }
}

- (UIColor *)ourPurple
{
    UIColor *ourPurple = [UIColor colorWithRed:150.0/255.0 green:0/255.0 blue:180.0/255.0 alpha:1.0];
    
    return ourPurple;
}

- (UIColor *)textGrayColor
{
    UIColor *textGrayColor = [UIColor colorWithRed:145.0/255.0 green:145.0/255.0 blue:160.0/255.0 alpha:1.0];
    
    return textGrayColor;
}

- (UIColor *)darkTextGrayColor
{
    UIColor *darkTextGrayColor = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:115.0/255.0 alpha:1.0];
    
    return darkTextGrayColor;
}

- (UIColor *)blackColor
{
    UIColor *blackColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:65.0/255.0 alpha:1.0];
    
    return blackColor;
}

- (UIButton *)actionButton
{
    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    CGFloat x = 20;
    CGFloat y = 20;
    CGFloat width = self.window.frame.size.width - x * 2;
    CGFloat height = 44;
    
    [actionButton setFrame:CGRectMake(x, y, width, height)];
    [[actionButton layer] setCornerRadius:8.0];
    [[actionButton layer] setMasksToBounds:YES];
    [[actionButton titleLabel] setFont:[UIFont fontWithName:@"Avenir-Medium" size:19.0]];
    
    return actionButton;
}

- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (NSNumber *)setPhotoSum:(Deal *)deal {
    
    if (deal.photoURL1.length > 2 && ![deal.photoURL1 isEqualToString:@"None"])
        deal.photoSum = @(deal.photoSum.intValue + 1);
    else
        return [NSNumber numberWithInt:0];
    
    if (deal.photoURL2.length > 2 && ![deal.photoURL2 isEqualToString:@"None"])
        deal.photoSum = @(deal.photoSum.intValue + 1);
    else
        return [NSNumber numberWithInt:1];
    
    if (deal.photoURL3.length > 2 && ![deal.photoURL3 isEqualToString:@"None"])
        deal.photoSum = @(deal.photoSum.intValue + 1);
    else
        return [NSNumber numberWithInt:2];
    
    if (deal.photoURL4.length > 2 && ![deal.photoURL4 isEqualToString:@"None"])
        deal.photoSum = @(deal.photoSum.intValue + 1);
    else
        return [NSNumber numberWithInt:3];
    
    return [NSNumber numberWithInt:4];
}

- (NSMutableArray *)photosURLArray:(Deal *)deal
{
    NSMutableArray *photosURLArray = [[NSMutableArray alloc] init];
    
    if (deal.photoURL1.length > 2 && ![deal.photoURL1 isEqualToString:@"None"])
        [photosURLArray addObject:deal.photoURL1];
    
    if (deal.photoURL2.length > 2 && ![deal.photoURL2 isEqualToString:@"None"])
        [photosURLArray addObject:deal.photoURL2];
    
    if (deal.photoURL3.length > 2 && ![deal.photoURL3 isEqualToString:@"None"])
        [photosURLArray addObject:deal.photoURL3];
    
    if (deal.photoURL4.length > 2 && ![deal.photoURL4 isEqualToString:@"None"])
        [photosURLArray addObject:deal.photoURL4];
    
    return photosURLArray;
}

- (UIImageView *)loadingAnimationWhite
{
    UIImageView *loadingAnimationView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30.0, 30.0)];
    
    loadingAnimationView.animationImages = [self loadingAnimationWhiteImages];
    
    loadingAnimationView.animationDuration = 0.3;
    
    return loadingAnimationView;
}

- (UIImageView *)loadingAnimationPurple
{
    UIImageView *loadingAnimationView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30.0, 30.0)];
    
    loadingAnimationView.animationImages = [self loadingAnimationPurpleImages];
    
    loadingAnimationView.animationDuration = 0.3;
    
    return loadingAnimationView;
}

- (NSArray *)loadingAnimationWhiteImages
{
    NSArray *loadingAnimationImages = [NSArray arrayWithObjects:
                                       [UIImage imageNamed:@"Loadingwhite"],
                                       [UIImage imageNamed:@"Loading5white"],
                                       [UIImage imageNamed:@"Loading10white"],
                                       [UIImage imageNamed:@"Loading15white"],
                                       [UIImage imageNamed:@"Loading20white"],
                                       [UIImage imageNamed:@"Loading25white"],
                                       [UIImage imageNamed:@"Loading30white"],
                                       [UIImage imageNamed:@"Loading35white"],
                                       [UIImage imageNamed:@"Loading40white"],
                                       [UIImage imageNamed:@"Loading45white"],
                                       [UIImage imageNamed:@"Loading50white"],
                                       [UIImage imageNamed:@"Loading55white"],
                                       [UIImage imageNamed:@"Loading60white"],
                                       [UIImage imageNamed:@"Loading65white"],
                                       [UIImage imageNamed:@"Loading70white"],
                                       [UIImage imageNamed:@"Loading75white"],
                                       [UIImage imageNamed:@"Loading80white"],
                                       [UIImage imageNamed:@"Loading85white"],
                                       nil];
    return loadingAnimationImages;
}

- (NSArray *)loadingAnimationPurpleImages
{
    NSArray *loadingAnimationImages = [NSArray arrayWithObjects:
                                       [UIImage imageNamed:@"loading"],
                                       [UIImage imageNamed:@"loading5"],
                                       [UIImage imageNamed:@"loading10"],
                                       [UIImage imageNamed:@"loading15"],
                                       [UIImage imageNamed:@"loading20"],
                                       [UIImage imageNamed:@"loading25"],
                                       [UIImage imageNamed:@"loading30"],
                                       [UIImage imageNamed:@"loading35"],
                                       [UIImage imageNamed:@"loading40"],
                                       [UIImage imageNamed:@"loading45"],
                                       [UIImage imageNamed:@"loading50"],
                                       [UIImage imageNamed:@"loading55"],
                                       [UIImage imageNamed:@"loading60"],
                                       [UIImage imageNamed:@"loading65"],
                                       [UIImage imageNamed:@"loading70"],
                                       [UIImage imageNamed:@"loading75"],
                                       [UIImage imageNamed:@"loading80"],
                                       [UIImage imageNamed:@"loading85"],
                                       nil];
    return loadingAnimationImages;
}

- (UIImageView *)contentModeForImageView:(UIImageView *)imageView
{
    if (imageView.image) {
        CGFloat ratio = imageView.image.size.height / imageView.image.size.width;
        if (ratio > 0.52 && ratio < 0.81) {
            // Gives a ratio of between 320:180 to 320:240
            imageView.contentMode = UIViewContentModeScaleAspectFill;
        } else {
            imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
    }
    return imageView;
}


#pragma mark - Dictionaries & Arrays

- (NSDictionary *)getCurrenciesDictionary
{
    NSDictionary *currencies = @{
                                 @"SH" : @"₪",
                                 @"DO" : @"$",
                                 @"PO" : @"£",
                                 @"YE" : @"¥",
                                 @"EU" : @"€"
                                 };
    return currencies;
}

- (NSString *)getCurrencySign:(NSString *)currencyKey
{
    NSDictionary *currenciesDictionary = [self getCurrenciesDictionary];
    return [currenciesDictionary valueForKey:currencyKey];
}

- (NSString *)getCurrencyKey:(NSString *)currencySign
{
    NSDictionary *currenciesDictionary = [self getCurrenciesDictionary];
    NSArray *temp = [currenciesDictionary allKeysForObject:currencySign];
    return temp.firstObject;
}

- (NSDictionary *)getDiscountTypesDictionary
{
    NSDictionary *discountTypes = @{
                                    @"PP" : @"lastPrice",
                                    @"PE" : @"%"
                                    };
    return discountTypes;
}

- (NSString *)getDiscountType:(NSString *)discountKey
{
    NSDictionary *discountTypes = [self getDiscountTypesDictionary];
    return [discountTypes valueForKey:discountKey];
}

- (NSString *)getDiscountKey:(NSString *)discountType
{
    NSDictionary *discountTypes = [self getDiscountTypesDictionary];
    NSArray *temp = [discountTypes allKeysForObject:discountType];
    return temp.firstObject;
}

- (NSArray *)getCategories
{
    NSString *art = NSLocalizedString(@"Art", nil);
    NSString *automotive = NSLocalizedString(@"Automotive", nil);
    NSString *beautyAndPersonalCare = NSLocalizedString(@"Beauty & Personal Care", nil);
    NSString *booksAndMagazines = NSLocalizedString(@"Books & Magazines", nil);
    NSString *electronics = NSLocalizedString(@"Electronics", nil);
    NSString *entertainmentAndEvents = NSLocalizedString(@"Entertainment & Events", nil);
    NSString *fashion = NSLocalizedString(@"Fashion", nil);
    NSString *foodAndGroceries = NSLocalizedString(@"Food & Groceries", nil);
    NSString *homeAndFurniture = NSLocalizedString(@"Home & Furniture", nil);
    NSString *kidsAndBabies = NSLocalizedString(@"Kids & Babies", nil);
    NSString *music = NSLocalizedString(@"Music", nil);
    NSString *pets = NSLocalizedString(@"Pets", nil);
    NSString *restaurantsAndBars = NSLocalizedString(@"Restaurants & Bars", nil);
    NSString *sportsAndOutdoor = NSLocalizedString(@"Sports & Outdoor", nil);
    NSString *travel = NSLocalizedString(@"Travel", nil);
    NSString *other = NSLocalizedString(@"Other", nil);
    
    NSArray *categories = [[NSMutableArray alloc] initWithObjects:art, automotive, beautyAndPersonalCare, booksAndMagazines, electronics, entertainmentAndEvents, fashion, foodAndGroceries, homeAndFurniture, kidsAndBabies, music, pets, restaurantsAndBars, sportsAndOutdoor, travel, other, nil];
    
    return categories;
}

- (NSArray *)getCategoriesIcons
{
    NSArray *icons = [[NSMutableArray alloc] initWithObjects:@"Art",@"Automotive",@"Beauty & Personal Care",@"Books & Magazines",@"Electronics",@"Amusment & Entertainment",@"Fashion",@"Food & Groceries",@"Home & Furniture",@"Kids & Babies",@"Music",@"Pets",@"Restaurants & Bars",@"Sports & Outdoor",@"Travel",@"Other",nil];
    
    return icons;
}

- (NSDictionary *)getCategoriesDictionary
{
    NSDictionary *categories = @{
                                 @"Fa" : NSLocalizedString(@"Fashion", nil),
                                 @"Au" : NSLocalizedString(@"Automotive", nil),
                                 @"Ar" : NSLocalizedString(@"Art", nil),
                                 @"Be" : NSLocalizedString(@"Beauty & Personal Care", nil),
                                 @"Bo" : NSLocalizedString(@"Books & Magazines", nil),
                                 @"El" : NSLocalizedString(@"Electronics", nil),
                                 @"En" : NSLocalizedString(@"Entertainment & Events", nil),
                                 @"Fo" : NSLocalizedString(@"Food & Groceries", nil),
                                 @"Ho" : NSLocalizedString(@"Home & Furniture", nil),
                                 @"Ki" : NSLocalizedString(@"Kids & Babies", nil),
                                 @"Mu" : NSLocalizedString(@"Music", nil),
                                 @"Pe" : NSLocalizedString(@"Pets", nil),
                                 @"Re" : NSLocalizedString(@"Restaurants & Bars", nil),
                                 @"Sp" : NSLocalizedString(@"Sports & Outdoor", nil),
                                 @"Tr" : NSLocalizedString(@"Travel", nil),
                                 @"Ot" : NSLocalizedString(@"Other", nil)
                                 };
    return categories;
}

- (NSString *)getCategoryKeyForValue:(NSString *)value
{
    NSDictionary *categories = [self getCategoriesDictionary];
    
    NSArray *tempArray = [categories allKeysForObject:value];
    
    return tempArray.firstObject;
}

- (NSString *)getCategoryValueForKey:(NSString *)key
{
    NSDictionary *categories = [self getCategoriesDictionary];
    
    return [categories valueForKey:key];
}

- (NSString *)getEnglishGender:(NSString *)gender
{
    if ([gender isEqualToString:NSLocalizedString(@"Male", nil)]) {
        return @"Male";
        
    } else if ([gender isEqualToString:NSLocalizedString(@"Female", nil)]) {
        return @"Female";
    }
    return nil;
}


#pragma mark - RestKit

- (NSString *)baseURL
{
    return @"http://api.dealers-app.com";
//    return @"http://api.dealers-web.com";
}

- (NSString *)currentVersion
{
    return @"version 2.41";
}

- (RKObjectMapping *)dealMapping
{
    RKObjectMapping *dealMapping = [RKObjectMapping mappingForClass:[Deal class]];
    [dealMapping addAttributeMappingsFromDictionary: @{
                                                       @"id" : @"dealID",
                                                       @"type" : @"type",
                                                       @"title" : @"title",
                                                       @"price" : @"price",
                                                       @"currency" : @"currency",
                                                       @"discount_value" : @"discountValue",
                                                       @"discount_type" : @"discountType",
                                                       @"category" : @"category",
                                                       @"expiration" : @"expiration",
                                                       @"more_description" : @"moreDescription",
                                                       @"upload_date" : @"uploadDate",
                                                       @"photo1" : @"photoURL1",
                                                       @"photo2" : @"photoURL2",
                                                       @"photo3" : @"photoURL3",
                                                       @"photo4" : @"photoURL4"
                                                       }];
    
    RKObjectMapping *storeMapping = [self storeMapping];
    [dealMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"store"
                                                                                toKeyPath:@"store"
                                                                              withMapping:storeMapping]];
    
    RKObjectMapping *dealerMapping = [RKObjectMapping mappingForClass:[Dealer class]];
    [dealerMapping addAttributeMappingsFromDictionary: @{
                                                         @"id" : @"dealerID",
                                                         @"email" : @"email",
                                                         @"full_name" : @"fullName",
                                                         @"date_of_birth" : @"dateOfBirth",
                                                         @"gender" : @"gender",
                                                         @"location" : @"location",
                                                         @"about" : @"about",
                                                         @"photo" : @"photoURL",
                                                         @"register_date" : @"registerDate",
                                                         @"uploaded_deals" : @"uploadedDeals",
                                                         @"bad_reports_counter" : @"badReportsCounter",
                                                         @"score" : @"score",
                                                         @"rank" : @"rank",
                                                         @"reliability" : @"reliability",
                                                         @"uploaded_deals" : @"uploadedDeals",
                                                         @"liked_deals" : @"likedDeals",
                                                         @"shared_deals" : @"sharedDeals",
                                                         @"followings" : @"followings",
                                                         @"followed_by" : @"followedBy",
                                                         @"total_likes" : @"totalLikes",
                                                         @"total_shares" : @"totalShares"
                                                         }];
    
    [dealMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"dealer"
                                                                                toKeyPath:@"dealer"
                                                                              withMapping:dealerMapping]];
    
    RKObjectMapping *dealAttribMapping = [self dealAttribMapping];
    
    [dealMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"dealattribs"
                                                                                toKeyPath:@"dealAttrib"
                                                                              withMapping:dealAttribMapping]];
    
    RKObjectMapping *commentMapping = [self commentMapping];
    
    [dealMapping addRelationshipMappingWithSourceKeyPath:@"comments" mapping:commentMapping];
    
    return dealMapping;
}

- (RKObjectMapping *)addDealMapping
{
    RKObjectMapping *addDealMapping = [RKObjectMapping mappingForClass:[Deal class]];
    [addDealMapping addAttributeMappingsFromDictionary: @{
                                                          @"id" : @"dealID",
                                                          @"type" : @"type",
                                                          @"title" : @"title",
                                                          @"dealer" : @"dealer.dealerID",
                                                          @"price" : @"price",
                                                          @"currency" : @"currency",
                                                          @"discount_value" : @"discountValue",
                                                          @"discount_type" : @"discountType",
                                                          @"category" : @"category",
                                                          @"expiration" : @"expiration",
                                                          @"more_description" : @"moreDescription",
                                                          @"upload_date" : @"uploadDate",
                                                          @"photo1" : @"photoURL1",
                                                          @"photo2" : @"photoURL2",
                                                          @"photo3" : @"photoURL3",
                                                          @"photo4" : @"photoURL4"
                                                          }];
    
    RKObjectMapping *dealAttribMapping = [self dealAttribMapping];
    [addDealMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"dealattribs"
                                                                                   toKeyPath:@"dealAttrib"
                                                                                 withMapping:dealAttribMapping]];
    
    RKObjectMapping *storeMapping = [self storeMapping];
    [addDealMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"store"
                                                                                   toKeyPath:@"store"
                                                                                 withMapping:storeMapping]];
    
    return addDealMapping;
}

- (RKObjectMapping *)dealerMapping
{
    RKObjectMapping *dealerMapping = [RKObjectMapping mappingForClass:[Dealer class]];
    [dealerMapping addAttributeMappingsFromDictionary: @{
                                                         @"id" : @"dealerID",
                                                         @"email" : @"email",
                                                         @"full_name" : @"fullName",
                                                         @"date_of_birth" : @"dateOfBirth",
                                                         @"gender" : @"gender",
                                                         @"about" : @"about",
                                                         @"location" : @"location",
                                                         @"register_date" : @"registerDate",
                                                         @"user.username" : @"username",
                                                         @"user.password" : @"userPassword",
                                                         @"photo" : @"photoURL",
                                                         @"bad_reports_counter" : @"badReportsCounter",
                                                         @"score" : @"score",
                                                         @"rank" : @"rank",
                                                         @"reliability" : @"reliability",
                                                         @"uploaded_deals" : @"uploadedDeals",
                                                         @"liked_deals" : @"likedDeals",
                                                         @"shared_deals" : @"sharedDeals",
                                                         @"followings" : @"followings",
                                                         @"followed_by" : @"followedBy",
                                                         @"total_likes" : @"totalLikes",
                                                         @"total_shares" : @"totalShares",
                                                         @"invitation_counter" : @"invitationCounter"
                                                         }];
    
    RKObjectMapping *deviceMapping = [self deviceMapping];
    [dealerMapping addRelationshipMappingWithSourceKeyPath:@"devices" mapping:deviceMapping];
    
    [dealerMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"screen_counters"
                                                                                   toKeyPath:@"screenCounters"
                                                                                 withMapping:[self screenCountersMapping]]];
    
    return dealerMapping;
}

- (RKObjectMapping *)editProfileMapping
{
    RKObjectMapping *editProfileMapping = [RKObjectMapping requestMapping];
    [editProfileMapping addAttributeMappingsFromDictionary: @{
                                                              @"email" : @"email",
                                                              @"fullName" : @"full_name",
                                                              @"dateOfBirth" : @"date_of_birth",
                                                              @"gender" : @"gender",
                                                              @"about" : @"about",
                                                              @"location" : @"location",
                                                              @"username" : @"user.username",
                                                              @"photoURL" : @"photo"
                                                              }];
    return editProfileMapping;
}

- (RKObjectMapping *)storeMapping
{
    RKObjectMapping *storeMapping = [RKObjectMapping mappingForClass:[Store class]];
    [storeMapping addAttributeMappingsFromDictionary: @{
                                                        @"store_id" : @"storeID",
                                                        @"name" : @"name",
                                                        @"latitude" : @"latitude",
                                                        @"longitude" : @"longitude",
                                                        @"address" : @"address",
                                                        @"cc" :@"cc",
                                                        @"city" : @"city",
                                                        @"state" : @"state",
                                                        @"country" : @"country",
                                                        @"category_id" : @"categoryID",
                                                        @"url" : @"url",
                                                        @"phone" : @"phone",
                                                        @"verified_by_foursquare" : @"verifiedByFoursquare",
                                                        @"added" : @"added"
                                                        }];
    return storeMapping;
}

- (RKObjectMapping *)dealAttribMapping
{
    RKObjectMapping *dealAttribMapping = [RKObjectMapping mappingForClass:[DealAttrib class]];
    
    [dealAttribMapping addAttributeMappingsFromDictionary: @{
                                                             @"id" : @"dealAttribID",
                                                             @"deal" : @"dealID",
                                                             @"dealers_that_liked" : @"dealersThatLiked",
                                                             @"dealers_that_shared" : @"dealersThatShared",
                                                             @"deal_reliability" : @"dealReliability",
                                                             @"objective_rank" : @"objectiveRank"
                                                             }];
    
    return dealAttribMapping;
}

- (RKObjectMapping *)commentMapping
{
    RKObjectMapping *commentMapping = [RKObjectMapping mappingForClass:[Comment class]];
    [commentMapping addAttributeMappingsFromDictionary: @{
                                                          @"id" : @"commentID",
                                                          @"text" : @"text",
                                                          @"deal" : @"dealID",
                                                          @"upload_date" : @"uploadDate",
                                                          @"type" : @"type"
                                                          }];
    
    [commentMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"dealer"
                                                                                   toKeyPath:@"dealer"
                                                                                 withMapping:[self dealerMapping]]];
    
    return commentMapping;
}

- (RKObjectMapping *)addCommentMapping
{
    RKObjectMapping *addCommentMapping = [RKObjectMapping mappingForClass:[Comment class]];
    [addCommentMapping addAttributeMappingsFromDictionary: @{
                                                             @"id" : @"commentID",
                                                             @"text" : @"text",
                                                             @"deal" : @"dealID",
                                                             @"dealer" : @"dealer.dealerID",
                                                             @"upload_date" : @"uploadDate",
                                                             @"type" : @"type"
                                                             }];
    
    return addCommentMapping;
}

- (RKObjectMapping *)notificationMapping
{
    RKObjectMapping *notificationMapping = [RKObjectMapping mappingForClass:[Notification class]];
    [notificationMapping addAttributeMappingsFromDictionary: @{
                                                               @"id" : @"notificationID",
                                                               @"type" : @"type",
                                                               @"recipients" : @"recipients",
                                                               @"deal" : @"dealID",
                                                               @"weekly_deales_id" : @"weeklyDealsID",
                                                               @"subject_title" : @"subjectTitle",
                                                               @"subject_message" : @"subjectMessage",
                                                               @"date" : @"date"
                                                               }];
    
    [notificationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"notifying_dealer"
                                                                                        toKeyPath:@"dealer"
                                                                                      withMapping:[self dealerMapping]]];
    
    return notificationMapping;
}

- (RKObjectMapping *)addNotificationMapping
{
    RKObjectMapping *addNotificationMapping = [RKObjectMapping mappingForClass:[Notification class]];
    [addNotificationMapping addAttributeMappingsFromDictionary: @{
                                                                  @"id" : @"notificationID",
                                                                  @"type" : @"type",
                                                                  @"recipients" : @"recipients",
                                                                  @"notifying_dealer" : @"dealer.dealerID",
                                                                  @"deal" : @"dealID",
                                                                  @"date" : @"date"
                                                                  }];
    
    return addNotificationMapping;
}

- (RKObjectMapping *)likedDealsMapping
{
    RKObjectMapping *likedDealsMapping = [RKObjectMapping mappingForClass:[DealAttrib class]];
    [likedDealsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"deal"
                                                                                      toKeyPath:@"deal"
                                                                                    withMapping:[self dealMapping]]];
    
    return likedDealsMapping;
}

- (RKObjectMapping *)userMapping
{
    RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[User class]];
    [userMapping addAttributeMappingsFromDictionary: @{
                                                       @"id" : @"userID",
                                                       @"username" : @"username",
                                                       @"password" : @"userPassword"
                                                       }];
    
    return userMapping;
}

- (RKObjectMapping *)invitationMapping
{
    RKObjectMapping *invitationMapping = [RKObjectMapping mappingForClass:[Invitation class]];
    [invitationMapping addAttributeMappingsFromDictionary: @{
                                                             @"id" : @"invitationID",
                                                             @"dealer" : @"dealerID",
                                                             @"passcode" : @"passcode"
                                                             }];
    
    return invitationMapping;
}

- (RKObjectMapping *)deviceMapping
{
    RKObjectMapping *deviceMapping = [RKObjectMapping mappingForClass:[Device class]];
    [deviceMapping addAttributeMappingsFromDictionary: @{
                                                         @"id" : @"deviceID",
                                                         @"dealer" : @"dealerID",
                                                         @"udid" : @"UDID",
                                                         @"token" : @"token",
                                                         @"os" : @"os",
                                                         @"badge" : @"badge",
                                                         @"last_update_date" : @"lastUpdateDate",
                                                         @"creation_date" : @"creationDate"
                                                         }];
    
    return deviceMapping;
}

- (RKObjectMapping *)categoryMapping
{
    RKObjectMapping *categoryMapping = [RKObjectMapping mappingForClass:[Category class]];
    [categoryMapping addAttributeMappingsFromDictionary: @{
                                                           @"id" : @"categoryID",
                                                           @"dealer" : @"dealerID",
                                                           @"category" : @"categoryKey"
                                                           }];
    
    return categoryMapping;
}

- (RKObjectMapping *)paginationMapping
{
    RKObjectMapping *paginationMapping = [RKObjectMapping mappingForClass:[RKPaginator class]];
    
    [paginationMapping addAttributeMappingsFromDictionary:@{
                                                            @"per_page": @"perPage",
                                                            @"total_pages": @"pageCount",
                                                            @"count": @"objectCount"
                                                            }];
    
    return paginationMapping;
}

- (RKObjectMapping *)screenCountersMapping
{
    RKObjectMapping *screenCounterMapping = [RKObjectMapping mappingForClass:[ScreenCounters class]];
    
    [screenCounterMapping addAttributeMappingsFromDictionary:@{
                                                            @"id": @"screenCountersID",
                                                            @"dealer": @"dealerID",
                                                            @"my_feed": @"myFeed",
                                                            @"explore": @"explore",
                                                            @"profile": @"profile",
                                                            @"activity": @"activity",
                                                            @"where_is_the_deal_local": @"whereIsTheDealLocal",
                                                            @"where_is_the_deal_online": @"whereIsTheDealOnline",
                                                            @"what_is_the_deal_local": @"whatIsTheDealLocal",
                                                            @"what_is_the_deal_online": @"whatIsTheDealOnline",
                                                            @"have_more_details": @"haveMoreDetails",
                                                            @"view_deal": @"viewDeal"
                                                            }];
    
    return screenCounterMapping;
}

- (RKObjectMapping *)scoreGuideMapping
{
    RKObjectMapping *scoreGuideMapping = [RKObjectMapping mappingForClass:[ScoreGuide class]];
    
    [scoreGuideMapping addAttributeMappingsFromDictionary:@{
                                                            @"dealer": @"dealer",
                                                            @"pro_dealer": @"proDealer",
                                                            @"senior_dealer": @"seniorDealer",
                                                            @"master_dealer" : @"masterDealer"
                                                            }];
    
    return scoreGuideMapping;
}

- (RKObjectMapping *)errorMapping
{
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[Error class]];
    
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"email" toKeyPath:@"emailFormat"]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"user" toKeyPath:@"emailExists"]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"username" toKeyPath:@"pseudoUserExists"]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"detail" toKeyPath:@"detail"]];
    
    return errorMapping;
}

- (RKObjectMapping *)reportMapping
{
    RKObjectMapping *deviceMapping = [RKObjectMapping mappingForClass:[Report class]];
    [deviceMapping addAttributeMappingsFromDictionary: @{
                                                         @"id" : @"reportID",
                                                         @"title" : @"dealID",
                                                         @"report" : @"report",
                                                         @"dealer" : @"reportingDealerID"
                                                         }];
    
    return deviceMapping;
}

- (void)setHTTPClientUsername:(NSString *)username andPassword:(NSString *)password
{
    [[RKObjectManager sharedManager].HTTPClient setAuthorizationHeaderWithUsername:username password:password];
}

- (void)resetHTTPClientUsernameAndPassword
{
    [[RKObjectManager sharedManager].HTTPClient setAuthorizationHeaderWithUsername:@"ubuntu" password:@"090909deal"];
}

- (void)configureRestKit
{
    // initialize AFNetworking HTTPClient
    NSURL *baseURL = [NSURL URLWithString:[self baseURL]];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit
    RKObjectManager *manager = [[RKObjectManager alloc] initWithHTTPClient:client];
    manager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    // validate with username and password
    NSString *username = @"ubuntu";
    NSString *password = @"090909deal";
    [manager.HTTPClient setAuthorizationHeaderWithUsername:username password:password];
    
    // other modifications to the object manager
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    // adding pagination mapping
    manager.paginationMapping = [self paginationMapping];
    
    // register mappings with the provider using response descriptors
    RKResponseDescriptor *myFeedResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self dealMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/my_feeds/"
                                                keyPath:@"results"
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *categoryDealsResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self dealMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/category_deals/"
                                                keyPath:@"results"
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *searchDealsResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self dealMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/dealsearch/"
                                                keyPath:@"results"
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *specificDealResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self dealMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/alldeals/:alldealID/"
                                                keyPath:nil
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *addDealResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self addDealMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/adddeals/"
                                                keyPath:nil
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *editDealResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self addDealMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/adddeals/:adddealID/"
                                                keyPath:nil
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *dealersResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self dealerMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/dealers/"
                                                keyPath:nil
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *signInResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self dealerMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/dealerlogins/"
                                                keyPath:@"results"
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *uploadedDealsResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self dealMapping]
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/uploadeddeals/:uploadeddealID/"
                                                keyPath:@"uploaded_deals"
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *likedDealsResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self likedDealsMapping]
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/likeddeals/:likeddealID/"
                                                keyPath:@"liked_deals"
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *weeklyDealsResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self dealMapping]
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/send_weekly_notifications/:send_weekly_notificationID/"
                                                keyPath:@"weekly_deal"
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *specificDealerResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self dealerMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/dealers/:dealerID/"
                                                keyPath:nil
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *likersResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self dealerMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/dealerslikeddeals/:dealerslikeddealID/"
                                                keyPath:@"dealers_that_liked"
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *dealAttribResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self dealAttribMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/dealattribs/:dealattribID/"
                                                keyPath:nil
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *commentsResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self commentMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/comments/"
                                                keyPath:nil
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *addCommentResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self addCommentMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/addcomments/"
                                                keyPath:nil
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *notificationResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self notificationMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/dealernotifications/:dealernotificationID/"
                                                keyPath:@"notifications"
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *addNotificationResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self addNotificationMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/addnotifications/"
                                                keyPath:nil
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *userResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self userMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/users/"
                                                keyPath:nil
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *specificUserResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self userMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/users/:userID/"
                                                keyPath:nil
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *facebookDealerResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self dealerMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/dealerfbs/"
                                                keyPath:@"results"
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *invitationResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self invitationMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/invitations/"
                                                keyPath:nil
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *specificInvitationResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self invitationMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/invitations/:invitationID/"
                                                keyPath:nil
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *deviceResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self deviceMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/devices/"
                                                keyPath:nil
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *deviceCheckResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self deviceMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/devices/"
                                                keyPath:@"results"
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *categoriesResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self categoryMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/dealer_cats/:dealer_catID/"
                                                keyPath:@"dealer_categorys"
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *categoryResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self categoryMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/dealer_categorys/"
                                                keyPath:nil
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *categoryDeleteResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self categoryMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/dealer_categorys/:dealer_categoryID/"
                                                keyPath:nil
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *specificDeviceResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self deviceMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/devices/:deviceID/"
                                                keyPath:nil
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *invitationSerachResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self invitationMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/invitations/"
                                                keyPath:@"results"
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *screenCountersPostResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self screenCountersMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/screen_counters/"
                                                keyPath:nil
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *screenCountersResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self screenCountersMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/screen_counters/:screen_counterID/"
                                                keyPath:nil
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *scoreGuideResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self scoreGuideMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/score_tables/"
                                                keyPath:@"results"
                                            statusCodes:statusCodes];
    
    RKResponseDescriptor *signUpErrorResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self errorMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:nil
                                                keyPath:nil
                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    
    RKResponseDescriptor *reportResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self reportMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:@"/reportdeals/"
                                                keyPath:nil
                                            statusCodes:statusCodes];
    
    // register mappings with the provider using request descriptors
    
    // for Registration
    RKRequestDescriptor *signUpRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:[[self dealerMapping] inverseMapping]
                                          objectClass:[Dealer class]
                                          rootKeyPath:nil
                                               method:RKRequestMethodAny];
    
    // for Add Deal & Edit Deal
    RKRequestDescriptor *addDealRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:[[self addDealMapping] inverseMapping]
                                          objectClass:[Deal class]
                                          rootKeyPath:nil
                                               method:RKRequestMethodAny];
    
    // for Deal Attrib update
    RKRequestDescriptor *dealAttribRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:[[self dealAttribMapping] inverseMapping]
                                          objectClass:[DealAttrib class]
                                          rootKeyPath:nil
                                               method:RKRequestMethodAny];
    
    // for adding Comment
    RKRequestDescriptor *addCommentRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:[[self addCommentMapping] inverseMapping]
                                          objectClass:[Comment class]
                                          rootKeyPath:nil
                                               method:RKRequestMethodAny];
    
    // for adding Notification
    RKRequestDescriptor *addNotificationRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:[[self addNotificationMapping] inverseMapping]
                                          objectClass:[Notification class]
                                          rootKeyPath:nil
                                               method:RKRequestMethodAny];
    
    // for adding Pseudo User
    RKRequestDescriptor *userRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:[[self userMapping] inverseMapping]
                                          objectClass:[User class]
                                          rootKeyPath:nil
                                               method:RKRequestMethodAny];
    
    // for posting Invitation
    RKRequestDescriptor *invitationRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:[[self invitationMapping] inverseMapping]
                                          objectClass:[Invitation class]
                                          rootKeyPath:nil
                                               method:RKRequestMethodAny];
    
    // for Device update
    RKRequestDescriptor *deviceRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:[[self deviceMapping] inverseMapping]
                                          objectClass:[Device class]
                                          rootKeyPath:nil
                                               method:RKRequestMethodAny];

    // for Screen Counters post & update
    RKRequestDescriptor *screenCountersRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:[[self screenCountersMapping] inverseMapping]
                                          objectClass:[ScreenCounters class]
                                          rootKeyPath:nil
                                               method:RKRequestMethodAny];
    
    // for Category update
    RKRequestDescriptor *categoryRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:[[self categoryMapping] inverseMapping]
                                          objectClass:[Category class]
                                          rootKeyPath:nil
                                               method:RKRequestMethodAny];
    
    // for Report Dealer
    RKRequestDescriptor *reportRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:[[self reportMapping] inverseMapping]
                                          objectClass:[Report class]
                                          rootKeyPath:nil
                                               method:RKRequestMethodAny];
    
    
    [manager addResponseDescriptorsFromArray:@[
                                               myFeedResponseDescriptor,
                                               categoryDealsResponseDescriptor,
                                               searchDealsResponseDescriptor,
                                               addDealResponseDescriptor,
                                               editDealResponseDescriptor,
                                               specificDealResponseDescriptor,
                                               dealersResponseDescriptor,
                                               signInResponseDescriptor,
                                               uploadedDealsResponseDescriptor,
                                               likedDealsResponseDescriptor,
                                               weeklyDealsResponseDescriptor,
                                               specificDealerResponseDescriptor,
                                               likersResponseDescriptor,
                                               dealAttribResponseDescriptor,
                                               commentsResponseDescriptor,
                                               addCommentResponseDescriptor,
                                               notificationResponseDescriptor,
                                               addNotificationResponseDescriptor,
                                               userResponseDescriptor,
                                               specificUserResponseDescriptor,
                                               facebookDealerResponseDescriptor,
                                               invitationResponseDescriptor,
                                               specificInvitationResponseDescriptor,
                                               invitationSerachResponseDescriptor,
                                               deviceResponseDescriptor,
                                               deviceCheckResponseDescriptor,
                                               categoriesResponseDescriptor,
                                               categoryResponseDescriptor,
                                               categoryDeleteResponseDescriptor,
                                               specificDeviceResponseDescriptor,
                                               screenCountersPostResponseDescriptor,
                                               screenCountersResponseDescriptor,
                                               scoreGuideResponseDescriptor,
                                               signUpErrorResponseDescriptor,
                                               reportResponseDescriptor
                                               ]];
    
    [manager addRequestDescriptorsFromArray:@[
                                              signUpRequestDescriptor,
                                              addDealRequestDescriptor,
                                              dealAttribRequestDescriptor,
                                              addCommentRequestDescriptor,
                                              addNotificationRequestDescriptor,
                                              userRequestDescriptor,
                                              invitationRequestDescriptor,
                                              deviceRequestDescriptor,
                                              screenCountersRequestDescriptor,
                                              categoryRequestDescriptor,
                                              reportRequestDescriptor
                                              ]];
}


#pragma mark - Facebook

- (void)openActiveSessionWithPermissions:(NSArray *)permissions allowLoginUI:(BOOL)allowLoginUI
{
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:allowLoginUI
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      
                                      if (!error) {
                                          
                                          if (permissions) {
                                              
                                              // Create a NSDictionary object and set the parameter values.
                                              NSDictionary *sessionStateInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                                                session, @"session",
                                                                                [NSNumber numberWithInteger:status], @"state",
                                                                                error, @"error",
                                                                                nil];
                                              
                                              // Create a new notification, add the sessionStateInfo dictionary to it and post it.
                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"SessionStateChangeNotification"
                                                                                                  object:nil
                                                                                                userInfo:sessionStateInfo];
                                              
                                          } else {
                                              
                                          }
                                          
                                      } else {
                                          
                                          NSLog(@"Error: %@", [error localizedDescription]);
                                          UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Can't connect Facebook"
                                                                                         message:nil
                                                                                        delegate:nil
                                                                               cancelButtonTitle:@"Ok"
                                                                               otherButtonTitles:nil];
                                          [alert show];
                                      }
                                  }];
}

- (BOOL)isFacebookConnected
{
    if ([FBSession activeSession].state == FBSessionStateOpen || [FBSession activeSession].state == FBSessionStateOpenTokenExtended) {
        return YES;
    }
    return NO;
}

- (void)configureFacebookRestKit
{
    self.updateFromFacebookManager = [[RKObjectManager alloc] initWithHTTPClient:[RKObjectManager sharedManager].HTTPClient];
    
    RKResponseDescriptor *updateProfileResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[self dealerMapping]
                                                 method:RKRequestMethodAny
                                            pathPattern:nil
                                                keyPath:nil
                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKRequestDescriptor *updateProfileRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:[self editProfileMapping]
                                          objectClass:[Dealer class]
                                          rootKeyPath:nil
                                               method:RKRequestMethodAny];
    
    [self.updateFromFacebookManager addResponseDescriptor:updateProfileResponseDescriptor];
    [self.updateFromFacebookManager addRequestDescriptor:updateProfileRequestDescriptor];
}

- (void)updateDealerInfo:(Dealer *)dealer
{
    if (!self.updateFromFacebookManager) {
        [self configureFacebookRestKit];
    }
    
    NSString *path = [NSString stringWithFormat:@"/dealers/%@/", dealer.dealerID];
    
    [self.updateFromFacebookManager patchObject:dealer
                                           path:path
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            
                                            NSLog(@"Dealer updated successfully!");
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            
                                            NSLog(@"Couldn't update dealer, Error: %@", error);
                                        }];
}

- (Dealer *)updateDealer:(Dealer *)dealer withFacebookInfo:(FBGraphObject *)facebookInfo withPhoto:(BOOL)withPhoto
{
    BOOL newDealer;
    
    if (!dealer) {
        newDealer = YES;
        dealer = [[Dealer alloc] init];
        dealer.registerDate = [NSDate date];
        dealer.fullName = [NSString stringWithFormat:@"%@ %@",
                           [facebookInfo objectForKey:@"first_name"],
                           [facebookInfo objectForKey:@"last_name"]];
        if ([facebookInfo objectForKey:@"email"]) {
            dealer.email = [facebookInfo objectForKey:@"email"];
            if (dealer.email.length > 30) {
                dealer.username = [dealer.email substringToIndex:30];
            } else {
                dealer.username = dealer.email;
            }
        } else {
            dealer.email = @"";
            dealer.username = [facebookInfo objectForKey:@"id"];
        }
        dealer.userPassword = [NSString stringWithFormat:@"facebook_user_%@", dealer.username];
        
    } else {
        newDealer = NO;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    dealer.dateOfBirth = [dateFormatter dateFromString:[facebookInfo objectForKey:@"birthday"]];
    
    if (!dealer.gender || [dealer.gender isEqualToString:@"Unspecified"]) {
        dealer.gender = [facebookInfo objectForKey:@"gender"];
        if ([dealer.gender isEqualToString:@"male"] || [dealer.gender isEqualToString:@"female"]) {
            
            NSString *capitalisedGender = [dealer.gender stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                                 withString:[[dealer.gender substringToIndex:1] capitalizedString]];
            dealer.gender = capitalisedGender;
        } else {
            dealer.gender = nil;
        }
    }
    
    if (!(dealer.location.length > 1) || [dealer.location isEqualToString:@"None"]) {
        NSString *location = [[facebookInfo objectForKey:@"location"] objectForKey:@"name"];
        dealer.location = location;
    }
    
    if (withPhoto) {
        if (!(dealer.photoURL.length > 1) || [dealer.photoURL isEqualToString:@"None"]) {
            
            NSURL *pictureURL = [NSURL URLWithString:[[[facebookInfo objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"]];
            
            NSString *photoFileName = [NSString stringWithFormat:@"%@_%f.jpg", dealer.username, [[NSDate date] timeIntervalSince1970]];
            NSString *filePathAtS3 = [NSString stringWithFormat:@"media/Profile_Photos/%@", photoFileName];
            dealer.photoURL = filePathAtS3;
            
            dealer.photo = [NSData dataWithContentsOfURL:pictureURL];
        }
    }
    
    if (!newDealer) {
        [self updateDealerInfo:dealer];
    }
    
    return dealer;
}

- (void)deletePseudoUser
{
    if (self.dealer.facebookPseudoUserID) {
        
        NSString *path = [NSString stringWithFormat:@"/users/%@/", self.dealer.facebookPseudoUserID];
        
        [[RKObjectManager sharedManager] deleteObject:nil
                                                 path:path
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  NSLog(@"Pseudo user deleted successfully!");
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  
                                                  NSLog(@"Couldn't delete pseudo user, Error: %@", error);
                                              }];
    }
}

#pragma mark - 3rt Party Frameworks

// Google Analytics

- (void)logButtonPress:(NSString *)eventLabel
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:eventLabel       // Event label
                                                           value:nil] build]];    // Event value
}

- (void)logPSEvent:(NSString *)eventLabel
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"app_action"     // Event category (required)
                                                          action:@"push_notification_press"  // Event action (required)
                                                           label:eventLabel       // Event label
                                                           value:nil] build]];    // Event value
}

// Intercom

- (void)intercomSuccessfulLogin {
    // Registering with Intercom is easy. For best results, use a unique user_id if you have one.
    NSString *userID = [NSString stringWithFormat:@"%@", self.dealer.dealerID];
    [Intercom registerUserWithUserId:userID];
}

- (void)intercomLogout {
    // This reset's the Intercom SDK's cache of your user's identity and wipes the slate clean.
    [Intercom reset];
}


#pragma mark - Other App Delegate Methods

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [self saveUserDetailsOnDevice];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
        
        [self openActiveSessionWithPermissions:nil allowLoginUI:NO];
    }
    [FBAppCall handleDidBecomeActive];
    
    if (tabBarController && [UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
        UITabBarItem *activityItem = [tabBarController.tabBar.items objectAtIndex:4];
        activityItem.badgeValue = [NSNumber numberWithInteger:[UIApplication sharedApplication].applicationIconBadgeNumber].stringValue;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [self saveUserDetailsOnDevice];
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}
@end
