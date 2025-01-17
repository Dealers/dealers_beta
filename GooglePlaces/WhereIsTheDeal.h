//
//  NewWhereIsTheDeal.h
//  Dealers
//
//  Created by Gilad Lumbroso on 3/11/15.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "StoreCategoriesOrganizer.h"
#import "StoreTableViewCell.h"
#import "WhatIsTheDeal1.h"
#import "AddStoreTableViewController.h"
#import "EditDealTableViewController.h"
#import "GAITrackedViewController.h"

@interface WhereIsTheDeal : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate> {
    
    CLLocationCoordinate2D currentCentre;
    CLLocationCoordinate2D lastCoords;
    CGFloat mapOriginalPosition, deviceScreenHeight;
    BOOL searchTextEmpty;
}

@property AppDelegate *appDelegate;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerYMapViewConstraint;
@property CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceSearchBarScrollViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceHideMapButtonConstraint;
@property (weak, nonatomic) IBOutlet UIButton *hideMapButton;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property RKObjectManager *foursquareManager;

@property (strong, nonatomic) NSMutableArray *storesNearby;
@property (strong, nonatomic) NSMutableArray *storesSearched;

@property UITableViewCell *customStoreCell;

@property (weak, nonatomic) IBOutlet UITableView *nearbyTableView;
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightNearByTableViewConstraint;
@property CGFloat nearbyTableViewMinHeight;
@property (weak, nonatomic) IBOutlet UIButton *searchBackgroundButton;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIImageView *loadingAnimation;
@property (weak, nonatomic) IBOutlet UILabel *loadingMessage;

@property WhatIsTheDeal1 *cashedInstance;
@property NSString *cameFrom;


@end
