//
//  AppDelegate.h
//  GooglePlaces
//
//  Created by van Lint Jason on 28/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "DealersTabBarController.h"
#import "Deal.h"
#import "Store.h"
#import "Dealer.h"
#import "DealAttrib.h"
#import "Comment.h"
#import "Notification.h"
#import "User.h"
#import "Invitation.h"
#import "Device.h"
#import "Error.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    int picsNumbers;
    NSInteger timesTriedToUpdateDevice, timesTriedToUpdateBadge;
    NSString *waitingForTabBarController;
    NSNumber *pushedDealID;
    NSDictionary *userInfoForActive;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) UIWindow *pushNotificationsWindow;
@property (nonatomic) UIStoryboard *storyboard;
@property (nonatomic) DealersTabBarController *tabBarController;
@property (strong, nonatomic)  NSString *Animate_first;
@property (strong, nonatomic)  NSString *UserID;
@property (strong, nonatomic)  NSString *AfterAddDeal;
@property (strong, nonatomic)  NSString *onlineOrLocal;
@property (strong, nonatomic)  NSString *previousViewControllerAddDeal;
@property (strong, nonatomic)  NSString *previousViewController;
@property (strong, nonatomic)  NSString *dealerName;
@property (strong, nonatomic)  UIImage *dealerProfileImage;
@property (strong, nonatomic)  Dealer *dealer;
@property BOOL shouldUpdateMyFeed;
@property BOOL shouldUpdateProfile;

@property NSMutableArray *pushedObjects;
@property Deal *pushedDeal;

@property RKObjectManager *updateFromFacebookManager;

@property (weak) UIImage *screenShot;


- (void)setTabBarController;
- (void)showPlusButton;
- (void)hidePlusButton;
- (void)resetBadgeCounter;
- (void)presentNotificationOfType:(NSString *)type;

- (void)saveUserDetailsOnDevice;
- (void)removeUserDetailsFromDevice;
- (NSData *)loadProfilePic;
- (void)updateUserInfo;
- (UIImage *)myProfilePic;
- (void)otherProfilePic:(Dealer *)dealer forTarget:(NSString *)target notificationName:(NSString *)notificationName atIndexPath:(NSIndexPath *)indexPath;
- (void)downloadPhotosForDeal:(Deal *)deal notificationName:(NSString *)notificationName atIndexPath:(NSIndexPath *)indexPath mode:(NSString *)mode;
- (void)sendNotificationOfType:(NSString *)type toRecipients:(NSArray *)recipients regardingTheDeal:(NSNumber *)dealID;
- (BOOL)didDealExpired:(Deal *)deal;
- (UIColor *)ourPurple;
- (UIColor *)textGrayColor;
- (UIColor *)darkTextGrayColor;
- (UIColor *)blackColor;
- (UIButton *)actionButton;
- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)newSize;
- (NSNumber *)setPhotoSum:(Deal *)deal;
- (Dealer *)updateDealer:(Dealer *)dealer withFacebookInfo:(FBGraphObject *)facebookInfo withPhoto:(BOOL)withPhoto;
- (void)deletePseudoUser;
- (NSString *)connectOldCategoryToNewCategory:(NSString *)string;

- (UIImageView *)loadingAnimationWhite;
- (UIImageView *)loadingAnimationPurple;

- (NSDictionary *)getCurrenciesDictionary;
- (NSString *)getCurrencySign:(NSString *)currencyKey;
- (NSString *)getCurrencyKey:(NSString *)currencySign;

- (NSDictionary *)getDiscountTypesDictionary;
- (NSString *)getDiscountType:(NSString *)discountKey;
- (NSString *)getDiscountKey:(NSString *)discountType;

- (NSArray *)getCategories;
- (NSArray *)getCategoriesIcons;
- (NSDictionary *)getCategoriesDictionary;
- (NSString *)getCategoryKeyForValue:(NSString *)value;
- (NSString *)getCategoryValueForKey:(NSString *)key;
- (NSString *)getEnglishGender:(NSString *)gender;

- (RKObjectMapping *)dealMapping;
- (RKObjectMapping *)addDealMapping;
- (RKObjectMapping *)dealerMapping;
- (RKObjectMapping *)editProfileMapping;
- (RKObjectMapping *)storeMapping;
- (RKObjectMapping *)dealAttribMapping;
- (RKObjectMapping *)commentMapping;
- (void)setHTTPClientUsername:(NSString *)username andPassword:(NSString *)password;
- (void)resetHTTPClientUsernameAndPassword;

- (void)openActiveSessionWithPermissions:(NSArray *)permissions allowLoginUI:(BOOL)allowLoginUI;
- (BOOL)isFacebookConnected;

@end
