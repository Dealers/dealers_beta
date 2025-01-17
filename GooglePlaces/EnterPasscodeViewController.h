//
//  EnterPasscodeViewController.h
//  Dealers
//
//  Created by Gilad Lumbroso on 1/12/15.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"
#import "OpeningScreenViewController.h"
#import "SignUpTableViewController.h"
#import "Invitation.h"
#import "MBProgressHUD.h"
#import "GAITrackedViewController.h"

@interface EnterPasscodeViewController : GAITrackedViewController <MFMailComposeViewControllerDelegate, MBProgressHUDDelegate, UITextFieldDelegate> {
    
    NSInteger deleteAttempt;
    BOOL explanationViewIsSet;
    MBProgressHUD *progressIndicator;
}

@property AppDelegate *appDelegate;

@property UINavigationController *navigationControllerDelegate;
@property BOOL signUp;
@property BOOL facebook;

@property (weak, nonatomic) IBOutlet UITextField *passcodeTextField;
@property (weak, nonatomic) IBOutlet UILabel *incorrectPasscode;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property UIImageView *checkmark;

@property UIBarButtonItem *barDone;
@property UIButton *done;
@property NSLayoutConstraint *doneHorizontalConstraint;

@property (weak, nonatomic) IBOutlet UIButton *whatIsThis;
@property UIButton *blackBackground;
@property (weak, nonatomic) IBOutlet UIView *explanationView;
@property (weak, nonatomic) IBOutlet UILabel *explanation;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceExplanationViewWhatIsThisConstraint;
@property (weak, nonatomic) IBOutlet UIView *explanationViewPointer;
@property (weak, nonatomic) IBOutlet UIButton *invitationRequest;


- (IBAction)whatIsThis:(id)sender;
- (IBAction)dismissExplanationView:(id)sender;
- (IBAction)requestPasscode:(id)sender;


@end
