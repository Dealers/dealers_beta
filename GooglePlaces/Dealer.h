//
//  dealerClass.h
//  Dealers-testbeta
//
//  Created by itzik berrebi on 6/4/14.
//
//

#import <Foundation/Foundation.h>

@class DealerAttrib;
@class Device;
@class ScreenCounters;

@interface Dealer : NSObject

@property NSNumber *dealerID;

@property NSString *username;
@property NSString *email;
@property NSString *userPassword;

@property NSString *fullName;
@property NSDate *dateOfBirth;
@property NSString *gender;
@property NSString *about;
@property NSString *location;

@property NSMutableArray *userLikesList;
@property NSString *photoURL;
@property NSData *photo;
@property BOOL downloadingPhoto;

@property NSDate *registerDate;
@property NSNumber *badReportsCounter;
@property NSNumber *score;
@property NSString *rank;
@property NSNumber *reliability;

@property NSMutableArray *uploadedDeals;
@property NSMutableArray *likedDeals;
@property NSMutableArray *sharedDeals;
@property NSMutableArray *followings;
@property NSMutableArray *followedBy;
@property NSNumber *totalLikes;
@property NSNumber *totalShares;

@property NSNumber *invitationCounter;

@property NSArray *devices;

@property ScreenCounters *screenCounters;

@property NSMutableArray *notifications;

@property NSNumber *facebookPseudoUserID;


@end
