//
//  WhatIsTheDeal2.h
//  Dealers
//
//  Created by Gilad Lumbroso on 10/2/14.
//
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <AWSS3/AWSS3.h>
#import "ChooseCategoryTableViewController.h"
#import "ThankYouViewController.h"
#import "DealTableViewCell.h"
#import "Deal.h"
#import "Dealer.h"
#import "Store.h"
#import "StoreCategoriesOrganizer.h"
#import "MBProgressHUD.h"
#import "ElasticLabel.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface WhatIsTheDeal2 : UITableViewController <UITextViewDelegate, UIActionSheetDelegate, UITextFieldDelegate, MBProgressHUDDelegate> {
    
    BOOL didUploadDealData;
    BOOL didDealPhotosFinishedUploading;
    UIColor *placeholder;
    CGFloat descriptionHeight;
    
    MBProgressHUD *illogicalPercentage, *lastPriceWithoutPrice, *loggingInFacebook;
}

@property AppDelegate *appDelegate;

@property Deal *deal;

@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UITextField *discountTextField;
@property NSString *selectedCurrency;
@property NSString *selectedDiscountType;

@property float priceValue;
@property float discountValue;

@property (retain, nonatomic) UIButton *shekel;
@property (retain, nonatomic) UIButton *dollar;
@property (retain, nonatomic) UIButton *euro;
@property (retain, nonatomic) UIButton *pound;
@property (retain, nonatomic) UIButton *percentage;
@property (retain, nonatomic) UIButton *lastPrice;

@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@property (weak, nonatomic) IBOutlet UILabel *expirationDateLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITableViewCell *datePickerCell;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) NSDateFormatter *dateFormatterDataBase;
@property BOOL datePickerIsShowing;
@property BOOL didTouchDatePicker;
@property BOOL didCancelDate;

@property (weak, nonatomic) IBOutlet ElasticLabel *descriptionPlaceholder;
@property (weak, nonatomic) IBOutlet UITextView *dealDescription;

@property (weak, nonatomic) IBOutlet UIView *addDealView;
@property UIButton *addDealButton;
@property UIView *addDealButtonBackground;
@property UIImageView *loadingAnimation;

@property NSString *cashedCategory;

@property BOOL hasPublishPermissions;

@property NSMutableArray *photosFileName;

@property UIImage *sharedImage;

// The Description Field (obsolete)
@property (weak, nonatomic) IBOutlet UILabel *moreDescriptionPlaceholder;
@property (weak, nonatomic) IBOutlet UITextView *moreDescriptionTextView;

@end
