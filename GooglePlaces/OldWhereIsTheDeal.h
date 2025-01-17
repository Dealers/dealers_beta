//
//  TableViewController.h
//  GooglePlaces
//
//  Created by itzik berrebi on 9/23/13.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <RestKit/RestKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "Store.h"
#import "StoreCategoriesOrganizer.h"

#define kGOOGLE_API_KEY @"AIzaSyCcDzlxbL52wI4wT_2y3iKqhrdCCo9WuUY"


@interface OldWhereIsTheDeal : UIViewController <UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate, CLLocationManagerDelegate,UISearchBarDelegate>
{
    CLLocationManager *_locationManager;
    NSString *imageName;
    BOOL firstLaunch;
    CLLocationCoordinate2D currentCentre;
    CLLocationCoordinate2D lastCoords;
    BOOL haveCoords;
    int currenDist;
    BOOL filtered;
    int SearchTextSize;
    BOOL didUpdateTheMap;
    BOOL currentVC;
    BOOL loadsuc;
}

@property UIApplication *app;

@property AppDelegate *appDelegate;

@property (nonatomic, strong) MKMapView *mapView;

@property RKObjectManager *foursquareManager;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *whiteCoverView;

@property (strong, nonatomic) IBOutlet UITableView *venuesTableView;
@property (strong, nonatomic) IBOutlet UITableView *storeSearchTableView;

@property (strong, nonatomic) NSMutableArray *storeNameArraySort;
@property (strong, nonatomic) NSMutableArray *storeLocationArraySort;
@property (strong, nonatomic) NSMutableArray *storeLatArraySort;
@property (strong, nonatomic) NSMutableArray *storeLongArraySort;
@property (strong, nonatomic) NSMutableArray *storeIconArraySort;
@property (strong, nonatomic) NSMutableArray *storeDistanceArraySort;
@property (strong, nonatomic) NSMutableArray *storeCategoryArraySort;
@property (strong, nonatomic) NSMutableArray *storeSearchLocationArray;
@property (strong, nonatomic) NSMutableArray *storeSearchNameArray;

@property (strong, nonatomic) NSMutableArray *storesNearby;
@property (strong, nonatomic) NSMutableArray *storesSearched;

@property (weak, nonatomic) IBOutlet UIButton *enlargeMapButton;
@property (weak, nonatomic) IBOutlet UIButton *collapseMapButton;
@property (weak, nonatomic) IBOutlet UIButton *closeStoreSearchTableButton;

@property (weak, nonatomic) IBOutlet UIImageView *theShadow;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *loadingImage;

@property (weak, nonatomic) IBOutlet UISearchBar *SearchBar;
@property CGRect venuesTableInitialFrame;

@property NSString *cameFrom;

- (IBAction)enlargeMapButtonClicked:(id)sender;
- (IBAction)collapseMapButtonClicked:(id)sender;
- (IBAction)closeStoreSearchTableButtonClicked:(id)sender;

@end
