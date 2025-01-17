//
//  SignInTableViewController.h
//  Dealers
//
//  Created by Gilad Lumbroso on 11/27/14.
//
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <AWSS3/AWSS3.h>
#import "KeychainItemWrapper.h"
#import "MBProgressHUD.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"


@interface SignInTableViewController : UITableViewController <UITextFieldDelegate, MBProgressHUDDelegate> {
    
    UIImageView *loadingAnimation;
    MBProgressHUD *blankEmail, *blankPassword, *noConnection, *wrongEmailPassword;
    BOOL didDownloadUserData;
    BOOL didPhotoFinishedDownloading;
    BOOL hasPhoto;
}

@property AppDelegate *appDelegate;

//@property RKObjectManager *signInManager;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIView *signInBackground;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

- (IBAction)signIn:(id)sender;

@end
