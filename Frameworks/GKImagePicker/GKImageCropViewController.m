//
//  GKImageCropViewController.m
//  GKImagePicker
//
//  Created by Georg Kitz on 6/1/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//

#import "GKImageCropViewController.h"
#import "GKImageCropView.h"

@interface GKImageCropViewController ()

@property (nonatomic, strong) GKImageCropView *imageCropView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *useButton;

- (void)_actionCancel;
- (void)_actionUse;
- (void)_setupNavigationBar;
- (void)_setupCropView;

@end

@implementation GKImageCropViewController

#pragma mark -
#pragma mark Getter/Setter

@synthesize sourceImage, cropSize, delegate;
@synthesize imageCropView;
@synthesize toolbar;
@synthesize cancelButton, useButton, resizeableCropArea;

#pragma mark -
#pragma Private Methods


- (void)_actionCancel{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)_actionUse{
    _croppedImage = [self.imageCropView croppedImage];
    [self.delegate imageCropController:self didFinishWithCroppedImage:_croppedImage];
}


- (void)_setupNavigationBar{
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                          target:self
                                                                                          action:@selector(_actionCancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Crop", @"")
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(_actionUse)];
}


- (void)_setupCropView{
    
    self.imageCropView = [[GKImageCropView alloc] initWithFrame:self.view.bounds];
    [self.imageCropView setImageToCrop:sourceImage];
    [self.imageCropView setResizableCropArea:self.resizeableCropArea];
    [self.imageCropView setCropSize:cropSize];
    [self.view addSubview:self.imageCropView];
}

- (void)_setupCancelButton{
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [[self.cancelButton titleLabel] setFont:[UIFont fontWithName:@"Avenir-Roman" size:18.0]];
    [self.cancelButton setTintColor:[UIColor whiteColor]];
    [self.cancelButton setFrame:CGRectMake(0, 0, 58, 30)];
    [self.cancelButton setTitle:NSLocalizedString(@"Cancel",@"") forState:UIControlStateNormal];
    [self.cancelButton  addTarget:self action:@selector(_actionCancel) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)_setupUseButton{
    
    self.useButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [[self.useButton titleLabel] setFont:[UIFont fontWithName:@"Avenir-Roman" size:18.0]];
    [self.useButton setTintColor:[UIColor whiteColor]];
    [self.useButton setFrame:CGRectMake(0, 0, 44, 30)];
    [self.useButton setTitle:NSLocalizedString(@"Crop",@"") forState:UIControlStateNormal];
    [self.useButton  addTarget:self action:@selector(_actionUse) forControlEvents:UIControlEventTouchUpInside];
}

- (UIImage *)_toolbarBackgroundImage{
    CGFloat components[] = {
        1., 1., 1., 1.,
        123./255., 125/255., 132./255., 1.
    };
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 54), YES, 0.0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
    
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, 0), CGPointMake(0, 54), kCGImageAlphaNoneSkipFirst);
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    
    return viewImage;
}

- (void)_setupToolbar{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        
        
        self.toolbar.translucent = YES;
        self.toolbar.barStyle = UIBarStyleBlackOpaque;
        [self.view addSubview:self.toolbar];
        
        [self _setupCancelButton];
        [self _setupUseButton];
        
        UILabel *info = [[UILabel alloc] initWithFrame:CGRectZero];
        info.text = @"";
        
        info.textColor = [UIColor colorWithRed:0.173 green:0.173 blue:0.173 alpha:1];
        info.backgroundColor = [UIColor clearColor];
        info.shadowColor = [UIColor colorWithRed:0.827 green:0.831 blue:0.839 alpha:1];
        info.shadowOffset = CGSizeMake(0, 1);
        info.font = [UIFont boldSystemFontOfSize:18];
        [info sizeToFit];
        
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithCustomView:self.cancelButton];
        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *lbl = [[UIBarButtonItem alloc] initWithCustomView:info];
        UIBarButtonItem *use = [[UIBarButtonItem alloc] initWithCustomView:self.useButton];
        
        [self.toolbar setItems:[NSArray arrayWithObjects:cancel, flex, lbl, flex, use, nil]];
        
    }
}

#pragma mark -
#pragma Super Class Methods

- (id)init{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"Pick you'r photo", @"");
    
    [self _setupNavigationBar];
    [self _setupCropView];
    [self _setupToolbar];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setNavigationBarHidden:YES];
    } else {
        [self.navigationController setNavigationBarHidden:NO];
    }
    self.view.clipsToBounds = YES;
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    self.imageCropView.frame = self.view.bounds;
    self.toolbar.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - 54, self.view.bounds.size.width, 54);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
