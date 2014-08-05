//
//  MainViewController.m
//  GooglePlaces
//
//  Created by itzik berrebi on 9/26/13.
//
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "Signup2ViewController.h"
#import "SigninViewController.h"

@interface MainViewController ()
@end

@implementation MainViewController
@synthesize facebookicon;
@synthesize twittericon;
@synthesize emailicon;
@synthesize i;
@synthesize backwhite,dealershead,via,already,signin;

-(void) ObjectInPlace {
   /* signin.alpha=1.0;
    already.alpha=1.0;
    via.alpha=1.0;
    backwhite.alpha=0.0;
    dealershead.alpha=1.0;
    dealershead.center = CGPointMake(160, 55+(ScreenHeight*[self isIphone5]));
//    facebookicon.center = CGPointMake(90, 178+(ScreenHeight*[self isIphone5]));
  //  twittericon.center = CGPointMake(58, 256+(ScreenHeight*[self isIphone5]));
    //emailicon.center = CGPointMake(86, 334+(ScreenHeight*[self isIphone5]));*/
}
- (void)viewDidLoad
{    
    ScreenHeight = self.view.frame.size.height/10;
    
    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if (([app.Animate_first isEqualToString:@"first"]) || (app.Animate_first == NULL))  {
        app.Animate_first=@"notfirst";
        signin.alpha=0.0;
        already.alpha=0.0;
        via.alpha=0.0;
        backwhite.alpha=1.0;
        dealershead.alpha=1.0;
        dealershead.center = CGPointMake(160,(CGRectGetMidY(app.window.bounds)-dealershead.frame.size.height/2-16));
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(anim2) userInfo:nil repeats:NO];
    } else {
        [self ObjectInPlace];
    }
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void) anim2 {
    [UIView animateWithDuration:1.0 animations:^{dealershead.center = CGPointMake(160, 55);}];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(anim) userInfo:nil repeats:NO];
}
-(void) anim {
    [UIView animateWithDuration:0.1 animations:^{backwhite.alpha=0.0;}];
    facebookicon.alpha=0.0;
    twittericon.alpha=0.0;
    emailicon.alpha=0.0;
    [UIView animateWithDuration:0.5 animations:^{facebookicon.alpha=1.0;}];
    [UIView animateWithDuration:0.5 animations:^{twittericon.alpha=1.0;}];
    [UIView animateWithDuration:0.5 animations:^{emailicon.alpha=1.0;}];
    [UIView animateWithDuration:0.5 animations:^{via.alpha=1.0;}];
    [UIView animateWithDuration:0.5 animations:^{already.alpha=1.0;}];
    [UIView animateWithDuration:0.5 animations:^{signin.alpha=1.0;}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)EmailimageButton:(id)sender{
    Signup2ViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Signup2ViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

-(IBAction)SigninButton:(id)sender{
    SigninViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"signin"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

-(int) isIphone5 {
    if ([[UIScreen mainScreen] bounds].size.height == 568) return 1;
    return 0;
}

-(void) deallocMemory
{
    NSLog(@"dealloc main");
    NSArray *viewsToRemove = [self.view subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    [self.view removeFromSuperview];
    self.view=nil;
}
@end
