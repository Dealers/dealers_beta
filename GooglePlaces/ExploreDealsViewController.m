//
//  ExploreDealsViewController.m
//  Dealers-testbeta
//
//  Created by itzik berrebi on 4/12/14.
//
//

#import "ExploreDealsViewController.h"
#import "ProfileViewController.h"
#import "ViewonedealViewController.h"
#import "MoreViewController.h"
#import "ExploretableViewController.h"
#import "AppDelegate.h"
#import "TableViewController.h"
#import "OnlineViewController.h"
#import "CheckConnection.h"

#define OFFSETSHORTCELL 109

@interface ExploreDealsViewController ()

@end

@implementation ExploreDealsViewController

-(void) checkIfThereIsNoDeals {
    [_loadingImage stopAnimating];
    if ([_dealsArray count]==0) {
        UILabel *label2=[[UILabel alloc]initWithFrame:CGRectMake(0, self.scrollView.center.y - 60, 320, 18)];
        [label2 setFont:[UIFont fontWithName:@"Avenir-Light" size:17.0]];
        [label2 setTextAlignment:NSTextAlignmentCenter];
        label2.text=@"There are no deals at this moment!";
        label2.backgroundColor=[UIColor clearColor];
        label2.textColor = [UIColor colorWithRed:(150/255.0) green:(150/255.0) blue:(155/255.0) alpha:1.0];
        [[self scrollView] addSubview:label2];
    } else NSLog(@"deals amount = %lu",(unsigned long)[_dealsArray count]);
}

-(void) startLoadingUploadImage:(UIImageView*)image {
    image.animationImages = [NSArray arrayWithObjects:
                             [UIImage imageNamed:@"loading.png"],
                             [UIImage imageNamed:@"loading5.png"],
                             [UIImage imageNamed:@"loading10.png"],
                             [UIImage imageNamed:@"loading15.png"],
                             [UIImage imageNamed:@"loading20.png"],
                             [UIImage imageNamed:@"loading25.png"],
                             [UIImage imageNamed:@"loading30.png"],
                             [UIImage imageNamed:@"loading35.png"],
                             [UIImage imageNamed:@"loading40.png"],
                             [UIImage imageNamed:@"loading45.png"],
                             [UIImage imageNamed:@"loading50.png"],
                             [UIImage imageNamed:@"loading55.png"],
                             [UIImage imageNamed:@"loading60.png"],
                             [UIImage imageNamed:@"loading65.png"],
                             [UIImage imageNamed:@"loading70.png"],
                             [UIImage imageNamed:@"loading75.png"],
                             [UIImage imageNamed:@"loading80.png"],
                             [UIImage imageNamed:@"loading85.png"],
                             nil];
    image.animationDuration = 0.3;
    [image startAnimating];
    [UIView animateWithDuration:0.2 animations:^{image.alpha=1.0; image.transform =CGAffineTransformMakeScale(0,0);
        image.transform =CGAffineTransformMakeScale(1,1);}];
}


-(void) loadDataFromDB {
    
    CheckConnection *checkconnection = [[CheckConnection alloc]init];
    if ([checkconnection connected]) {
        NSString * url= [NSString stringWithFormat:@"http://www.dealers.co.il/newExplore.php?Category='%@'",_categoryFromExplore];
        NSURL *dbRequestURL = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        NSData *data = [NSData dataWithContentsOfURL: dbRequestURL];
        NSError* error;
        
        if (data!=nil) {
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:kNilOptions
                                  error:&error];
            NSDictionary *responseData = json[@"respone"];
            NSArray *deals = responseData[@"deals"];
            NSLog(@"%lu",(unsigned long)[deals count]);
            
            for (int i=0; i<[deals count]-1 && deals!=NULL; i++)
            {
                DealClass *dealClass = [[DealClass alloc]init];
                NSDictionary *dealsDictionary = [deals objectAtIndex:i];
                [dealClass setDealTitle:[dealsDictionary objectForKey:@"title"]];
                [dealClass setDealStore:[dealsDictionary objectForKey:@"store"]];
                [dealClass setDealDescription:[dealsDictionary objectForKey:@"description"]];
                [dealClass setDealCurrency:[dealsDictionary objectForKey:@"currency"]];
                [dealClass setDealPrice:[dealsDictionary objectForKey:@"price"]];
                [dealClass setDealDiscount:[dealsDictionary objectForKey:@"discount"]];
                [dealClass setDealExpireDate:[dealsDictionary objectForKey:@"expire"]];
                [dealClass setDealLikesCount:[dealsDictionary objectForKey:@"likescount"]];
                [dealClass setDealCommentCount:[dealsDictionary objectForKey:@"commentscount"]];
                [dealClass setDealPhotoID1:[dealsDictionary objectForKey:@"photoid1"]];
                [dealClass setDealPhotoID2:[dealsDictionary objectForKey:@"photoid2"]];
                [dealClass setDealPhotoID3:[dealsDictionary objectForKey:@"photoid3"]];
                [dealClass setDealPhotoID4:[dealsDictionary objectForKey:@"photoid4"]];
                [dealClass setDealPhotoSum:[dealsDictionary objectForKey:@"photosum"]];
                [dealClass setDealCategory:[dealsDictionary objectForKey:@"category"]];
                [dealClass setDealUserID:[dealsDictionary objectForKey:@"userid"]];
                [dealClass setDealID:[dealsDictionary objectForKey:@"dealid"]];
                [dealClass setDealUploadDate:[dealsDictionary objectForKey:@"uploaddate"]];
                [dealClass setDealOnlineOrLocal:[dealsDictionary objectForKey:@"onlineorlocal"]];
                [dealClass setDealUrlSite:[dealsDictionary objectForKey:@"urlsite"]];
                [dealClass setDealStoreAddress:[dealsDictionary objectForKey:@"storeaddress"]];
                [dealClass setDealStoreLatitude:[dealsDictionary objectForKey:@"storelatitude"]];
                [dealClass setDealStoreLongitude:[dealsDictionary objectForKey:@"storelongitude"]];
                
                [_dealsArray addObject:dealClass];
            }
        }
    }
    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    app.AfterAddDeal=@"aftersign";
    
}

-(void) startLoadingUploadIcon:(UIImageView*)image {
    
    image.animationImages = [NSArray arrayWithObjects:
                             [UIImage imageNamed:@"loading.png"],
                             [UIImage imageNamed:@"loading5.png"],
                             [UIImage imageNamed:@"loading10.png"],
                             [UIImage imageNamed:@"loading15.png"],
                             [UIImage imageNamed:@"loading20.png"],
                             [UIImage imageNamed:@"loading25.png"],
                             [UIImage imageNamed:@"loading30.png"],
                             [UIImage imageNamed:@"loading35.png"],
                             [UIImage imageNamed:@"loading40.png"],
                             [UIImage imageNamed:@"loading45.png"],
                             [UIImage imageNamed:@"loading50.png"],
                             [UIImage imageNamed:@"loading55.png"],
                             [UIImage imageNamed:@"loading60.png"],
                             [UIImage imageNamed:@"loading65.png"],
                             [UIImage imageNamed:@"loading70.png"],
                             [UIImage imageNamed:@"loading75.png"],
                             [UIImage imageNamed:@"loading80.png"],
                             [UIImage imageNamed:@"loading85.png"],
                             nil];
    image.animationDuration = 0.3;
    [image startAnimating];
    [UIView animateWithDuration:0.2 animations:^{image.alpha=1.0; image.transform =CGAffineTransformMakeScale(0,0);
        image.transform =CGAffineTransformMakeScale(1,1);}];
}

-(void) createDealsTable {
    DealClass *dealClass = [[DealClass alloc]init];
    isUpdatingNow = YES;
    for (int i=cellNumberInScrollView; ((i<10+cellNumberInScrollView) && (i<[_dealsArray count])); i++) {
        dealClass = [_dealsArray objectAtIndex:i];
        NSString *num=[dealClass dealPhotoID1];
        
        if ([num isEqualToString:@"0"]) {
            isShortCell = YES;
        } else isShortCell = NO;
        
        UIImageView *imageview;
        if (isShortCell) {
            imageview=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"My Feed+View Deal - New Version_No Pic Deal background & Shadow.png"]];
        } else imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"My Feed+View Deal (final)_Deal background & Shadow.png"]];
        
        [imageview setFrame:CGRectMake(2.5, 4+(GAP), 315, 199-(OFFSETSHORTCELL*isShortCell))];
        [[self scrollView] addSubview:imageview];
        
        UIImageView *imageview4;
        if ([[dealClass dealOnlineOrLocal] isEqualToString:@"local"]) {
            imageview4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"My Feed+View Deal (final)_Local icon.png"]];
            [imageview4 setFrame:CGRectMake(18, 173+(GAP)-(OFFSETSHORTCELL*isShortCell), 11, 14)];
        } else {
            imageview4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"My Feed+View Deal - (final)_Online icon.png"]];
            [imageview4 setFrame:CGRectMake(17, 174+(GAP)-(OFFSETSHORTCELL*isShortCell), 13, 13)];
        }
        [[self scrollView] addSubview:imageview4];
        
        UILabel *label2=[[UILabel alloc]initWithFrame:CGRectMake(34, 168+(GAP)-(OFFSETSHORTCELL*isShortCell), 175, 24)];
        [label2 setFont:[UIFont fontWithName:@"Avenir-Roman" size:13.0]];
        label2.text=[dealClass dealStore];
        label2.backgroundColor=[UIColor clearColor];
        label2.textColor = [UIColor colorWithRed:(0/255.0) green:(0/255.0) blue:(0/255.0) alpha:1.0];
        [[self scrollView] addSubview:label2];
        
        if ((![[dealClass dealPrice] isEqualToString:@"0"])&&([[dealClass dealDiscount] isEqualToString:@"0"])) {
            UILabel *label3=[[UILabel alloc]initWithFrame:CGRectMake(265, 169+(GAP)-(OFFSETSHORTCELL*isShortCell), 53, 21)];
            [label3 setFont:[UIFont fontWithName:@"Avenir-Light" size:16.0]];
            label3.text=[dealClass dealPrice];
            label3.backgroundColor=[UIColor clearColor];
            label3.textColor = [UIColor blackColor];
            [label3 sizeToFit];
            label3.textAlignment=NSTextAlignmentRight;
            [[self scrollView] addSubview:label3];
        }
        
        if ((![[dealClass dealPrice] isEqualToString:@"0"])&&(![[dealClass dealDiscount] isEqualToString:@"0"])) {
            UILabel *label4=[[UILabel alloc]initWithFrame:CGRectMake(265, 169+(GAP)-(OFFSETSHORTCELL*isShortCell), 53, 21)];
            [label4 setFont:[UIFont fontWithName:@"Avenir-Light" size:16.0]];
            label4.text=[dealClass dealDiscount];
            label4.text = [label4.text stringByAppendingString:@"%"];
            label4.backgroundColor=[UIColor clearColor];
            label4.textColor = [UIColor colorWithRed:(255/255.0) green:(59/255.0) blue:(48/255.0) alpha:1.0];
            [label4 sizeToFit];
            label4.textAlignment=NSTextAlignmentRight;
            [[self scrollView] addSubview:label4];
            
            UILabel *label3=[[UILabel alloc]initWithFrame:CGRectMake(215, 169+(GAP)-(OFFSETSHORTCELL*isShortCell), 53, 21)];
            [label3 setFont:[UIFont fontWithName:@"Avenir-Light" size:16.0]];
            label3.text=[dealClass dealPrice];
            label3.backgroundColor=[UIColor clearColor];
            label3.textColor = [UIColor blackColor];
            label3.textAlignment=NSTextAlignmentRight;
            [label3 sizeToFit];
            [[self scrollView] addSubview:label3];
            
            
        }
        
        if (([[dealClass dealPrice] isEqualToString:@"0"])&&(![[dealClass dealDiscount] isEqualToString:@"0"])) {
            UILabel *label3=[[UILabel alloc]initWithFrame:CGRectMake(265, 169+(GAP)-(OFFSETSHORTCELL*isShortCell), 53, 21)];
            [label3 setFont:[UIFont fontWithName:@"Avenir-Light" size:16.0]];
            label3.text=[dealClass dealDiscount];
            label3.text = [label3.text stringByAppendingString:@"%"];
            label3.backgroundColor=[UIColor clearColor];
            label3.textColor = [UIColor redColor];
            [label3 sizeToFit];
            label3.textAlignment=NSTextAlignmentRight;
            [[self scrollView] addSubview:label3];
        }
        
        GAP=CGRectGetMaxY(imageview.frame)-4;
    }
    cellNumberInScrollView+=10;
    [[self scrollView] setContentSize:CGSizeMake(319,GAP)];
    isUpdatingNow = NO;
}
-(void) fillTheCellsWithImages {
    isUpdatingNow = YES;
    
    dispatch_queue_t queue = dispatch_queue_create("com.MyQueue", NULL);
    dispatch_async(queue, ^{
        // Do some computation here.
        DealClass *dealClass = [[DealClass alloc]init];
        for (int i=cellsNumbersInFillWithImages; ((i<cellNumberInScrollView) && (i<[_dealsArray count])); i++) {
            dealClass = [_dealsArray objectAtIndex:i];
            NSString *num=[dealClass dealPhotoID1];
            NSString *URLforphoto = [NSString stringWithFormat:@"http://www.dealers.co.il/%@.jpg",num];
            
            if (([num isEqualToString:@"0"])||(num==nil)||([num length]==0)) {
                [_dealPhotosArray addObject:@"0"];
            } else{
                _image2=[[UIImage alloc]init];
                _image2 =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:URLforphoto]]];
                [_dealPhotosArray addObject:_image2];
            }
        }
        // Update UI after computation.
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI on the main thread.
            DealClass *dealClass = [[DealClass alloc]init];
            for (int i=cellsNumbersInFillWithImages; ((i<cellNumberInScrollView) && (i<[_dealsArray count])); i++) {
                dealClass = [_dealsArray objectAtIndex:i];
                NSString *num=[dealClass dealPhotoID1];
                if ([num isEqualToString:@"0"]||([num length]==0)) {
                    isShortCell = YES;
                } else isShortCell = NO;
                
                UIImageView *imageview;
                if (isShortCell) {
                    imageview=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"My Feed+View Deal - New Version_No Pic Deal background & Shadow.png"]];
                } else imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"My Feed+View Deal (final)_Deal background & Shadow.png"]];
                [imageview setFrame:CGRectMake(2.5, 4+(gap2), 315, 199-(OFFSETSHORTCELL*isShortCell))];
                
                UIImageView *imageview2 = [[UIImageView alloc]init];
                if (isShortCell) {
                } else {
                    imageview2.image=[_dealPhotosArray objectAtIndex:i];
                    [imageview2 setFrame:CGRectMake(10, 10+(gap2), 300, 155)];
                    CALayer *mask = [CALayer layer];
                    mask.contents=(id)[[UIImage imageNamed:@"My Feed+View Deal (final)_Deal Pic mask.png"]CGImage];
                    mask.frame = CGRectMake(0, 0, 300, 155);
                    imageview2.layer.mask = mask;
                    imageview2.layer.masksToBounds = YES;
                    imageview2.tag=i;
                    if (!isShortCell) [[self scrollView] addSubview:imageview2];
                }
                UIImageView *imageview3;
                if (isShortCell) {
                    imageview3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"My Feed+View Deal - New Version_No Pic Deal Dark background.png"]];
                    [imageview3 setFrame:CGRectMake(10, 9+(gap2), 300, 47)];
                    
                } else { imageview3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"My Feed+View Deal (final)_Title & Store shade.png"]];
                    [imageview3 setFrame:CGRectMake(10, 87+(gap2)-(OFFSETSHORTCELL*isShortCell), 300, 78)];
                }
                [[self scrollView] addSubview:imageview3];
                
                UIImageView *imageview5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"My Feed+View Deal (final)_Likes icon.png"]];
                [imageview5 setFrame:CGRectMake(274, 124+(gap2)-(OFFSETSHORTCELL*isShortCell), 13, 12)];
                [[self scrollView] addSubview:imageview5];
                
                UIImageView *imageview6 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"My Feed+View Deal (final)_Comments icon.png"]];
                [imageview6 setFrame:CGRectMake(274, 143+(gap2)-(OFFSETSHORTCELL*isShortCell), 12, 14)];
                [[self scrollView] addSubview:imageview6];
                
                
                UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(18, 119+(gap2)-(OFFSETSHORTCELL*isShortCell), 249, 41)];
                [label setFont:[UIFont fontWithName:@"Avenir-Roman" size:14.0]];
                label.text=[dealClass dealTitle];
                label.backgroundColor=[UIColor clearColor];
                label.textColor = [UIColor whiteColor];
                label.numberOfLines=2;
                [[self scrollView] addSubview:label];
                
                UILabel *label5=[[UILabel alloc]initWithFrame:CGRectMake(291, 121+(gap2)-(OFFSETSHORTCELL*isShortCell), 21, 21)];
                [label5 setFont:[UIFont fontWithName:@"Avenir-Roman" size:13.0]];
                label5.text=[dealClass dealLikesCount];
                label5.backgroundColor=[UIColor clearColor];
                label5.textColor = [UIColor whiteColor];
                [label5 sizeToFit];
                [[self scrollView] addSubview:label5];
                
                UILabel *label6=[[UILabel alloc]initWithFrame:CGRectMake(291, 141+(gap2)-(OFFSETSHORTCELL*isShortCell), 21, 21)];
                [label6 setFont:[UIFont fontWithName:@"Avenir-Roman" size:13.0]];
                label6.text=[dealClass dealCommentCount];
                label6.backgroundColor=[UIColor clearColor];
                label6.textColor = [UIColor whiteColor];
                [label6 sizeToFit];
                [[self scrollView] addSubview:label6];
                
                UIButton *selectDealButton=[UIButton buttonWithType:UIButtonTypeCustom];
                [selectDealButton setTitle:@"" forState:UIControlStateNormal];
                selectDealButton.frame=CGRectMake(0, 4+(gap2), 319, 193-(OFFSETSHORTCELL*isShortCell));//193
                selectDealButton.tag=i;
                [selectDealButton addTarget:self action:@selector(selectDealButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
                [[self scrollView] addSubview:selectDealButton];
                gap2=CGRectGetMaxY(imageview.frame)-4;
            }
            cellsNumbersInFillWithImages+=10;
            isUpdatingNow = NO;
            [self checkIfThereIsNoDeals];
            
        });
    });
    
}
-(void) selectDealButtonClicked:(id)sender {
    ViewonedealViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"viewdeal"];
    UIButton *button = (UIButton *)sender;
    DealClass *dealClass = [[DealClass alloc]init];
    dealClass = [_dealsArray objectAtIndex:(button.tag)];
    controller.dealClass=dealClass;
    
    if (![[dealClass dealPhotoID1] isEqualToString:@"0"]) {
        controller.dealClass.dealPhoto1 = [_dealPhotosArray objectAtIndex:(button.tag)];
        controller.isShoetCell = @"no";
    } else controller.isShoetCell = @"yes";
    
    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString *FindURL = [NSString stringWithFormat:@"http://www.dealers.co.il/setLikeToDeal.php?Userid=%@&Indicator=%@",app.UserID,@"whatdealstheuserlikes"];
    NSData *URLData = [NSData dataWithContentsOfURL:[NSURL URLWithString:FindURL]];
    NSString *DataResult = [[NSString alloc] initWithData:URLData encoding:NSUTF8StringEncoding];
    _dealsUserLikes=DataResult;
    
    if ([_dealsUserLikes rangeOfString:[dealClass dealID]].location == NSNotFound) {
        controller.likeornotLabelFromMyFeeds=@"no";
        NSLog(@"didnt find");
    } else {
        controller.likeornotLabelFromMyFeeds=@"yes";
    }
    
    [self.navigationController pushViewController:controller animated:YES];
}
-(void)allocArrays {
    _dealsArray=Nil;
    _dealPhotosArray=Nil;
    _dealsArray = [[NSMutableArray alloc]init];
    _dealPhotosArray=[[NSMutableArray alloc]init];
}


-(void) didReachFromRegisterOrAddDeal {
    
    NSArray *viewsToRemove = [self.scrollView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    [self createDealsTable];
    [self fillTheCellsWithImages];
}

-(void) initialize {
    
    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    app.AfterAddDeal=@"aftertapbar";
    //self.onlineOrLocalView.alpha=0.0;
    //self.denyClickingOnCellsButton.alpha=0.0;
    //self.whiteCoverView.alpha=1.0;
    self.scrollView.frame = [[UIScreen mainScreen] bounds];
    [[self scrollView] setBackgroundColor:[UIColor colorWithRed:(230/255.0) green:(230/255.0) blue:(235/255.0) alpha:1.0]];
    [[self scrollView]setScrollEnabled:YES];
    isShortCell=NO;
    isUpdatingNow=NO;
    cellNumberInScrollView=0;
    cellsNumbersInFillWithImages=0;
    GAP=0;
    gap2=0;
    
    UILabel *label5=[[UILabel alloc]initWithFrame:CGRectMake(0, 44, 240, 29)];
    [label5 setFont:[UIFont fontWithName:@"Avenir-Next" size:54.0]];
    label5.text=_categoryFromExplore;
    label5.backgroundColor=[UIColor clearColor];
    label5.textColor = [UIColor colorWithRed:150/255.0 green:0/255.0 blue:180/255.0 alpha:1.0];
    [label5 sizeToFit];
    label5.center = CGPointMake(160, 22);
    [[self view] addSubview:label5];

}
//
- (void)viewDidLoad
{
    self.title = self.categoryFromExplore;
    [self initialize];
    [self allocArrays];
    //[self setRefreshControl];
    [self startLoadingUploadImage:_loadingImage];
    dispatch_queue_t queue = dispatch_queue_create("com.MyQueue", NULL);
    dispatch_async(queue, ^{
        // Do some computation here.
        [self loadDataFromDB];
        // Update UI after computation.
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI on the main thread.
            NSLog(@"creating cells");
            [self didReachFromRegisterOrAddDeal];
        });
    });
    [super viewDidLoad];
}
//
-(void)scrollViewDidScroll: (UIScrollView*)scrollView {
    int scrollOffset = scrollView.contentOffset.y + 300;
    if (((GAP - scrollOffset) < 200)&&(GAP!=0)) {
        if (!isUpdatingNow) {
            NSLog(@"scroll reach end, refreshing");
            isUpdatingNow = YES;
            [self createDealsTable];
            [self fillTheCellsWithImages];
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) deallocMemory {
    _dealPhotosArray=Nil;
    _dealsArray=Nil;
    
    static NSCache *_cache = nil;
    [_cache removeAllObjects];
    NSArray *viewsToRemove = [self.view subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    [self.view removeFromSuperview];
    self.view=nil;
}

- (IBAction)myfeedbutton:(id)sender{
    [self deallocMemory];
    NSArray *viewControllers = self.navigationController.viewControllers;
    UINavigationController * navigationController = self.navigationController;
    [navigationController popToViewController:[viewControllers objectAtIndex:2] animated:NO];
}
- (IBAction)morebutton:(id)sender{
    [self deallocMemory];
    NSArray *viewControllers = self.navigationController.viewControllers;
    UINavigationController * navigationController = self.navigationController;
    MoreViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"more"];
    
    [navigationController popToViewController:[viewControllers objectAtIndex:2] animated:NO];
    [navigationController pushViewController:controller animated:NO];
}

- (IBAction)profilebutton:(id)sender{
    [self deallocMemory];
    NSArray *viewControllers = self.navigationController.viewControllers;
    UINavigationController * navigationController = self.navigationController;
    ProfileViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"profile"];
    
    [navigationController popToViewController:[viewControllers objectAtIndex:2] animated:NO];
    [navigationController pushViewController:controller animated:NO];
}
- (IBAction)explorebutton:(id)sender{
}

- (IBAction)returnButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


//////////////////////
//// tapbar //////////
//////////////////////


-(void) func {
    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    app.previousViewControllerAddDeal=@"foursquare";
    app.onlineOrLocal=@"local";
    TableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"TableView"];
    UINavigationController *navigationController = self.navigationController;
    NSArray *viewControllers = self.navigationController.viewControllers;
    [navigationController popToViewController:[viewControllers objectAtIndex:2] animated:NO];
    [navigationController pushViewController:controller animated:NO];
}

-(void) func2 {
    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    app.previousViewControllerAddDeal=@"online";
    app.onlineOrLocal=@"online";
    OnlineViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"OnlineView"];
    UINavigationController *navigationController = self.navigationController;
    NSArray *viewControllers = self.navigationController.viewControllers;
    [navigationController popToViewController:[viewControllers objectAtIndex:2] animated:NO];
    [navigationController pushViewController:controller animated:NO];
}

-(void) goToOnline {
    [self hideLocalOrOnlineView];
    [self performSelector:@selector(func2) withObject:nil afterDelay:0.5];
}

-(void) goToAddDeal {
    [self hideLocalOrOnlineView];
    [self performSelector:@selector(func) withObject:nil afterDelay:0.1];
    
}

-(void) tapBarSet {
    
    UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"My Feed+View Deal_Tab Bar@2X.png"]];
    [imageview setFrame:CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height)-69, ([[UIScreen mainScreen] bounds].size.width), 50)];
    [[self view] addSubview:imageview];
    
    UIImageView *imageview2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"My Feed+View Deal_Explore button (selected)@2X.png"]];
    [imageview2 setFrame:CGRectMake(74, ([[UIScreen mainScreen] bounds].size.height)-64, 29, 29)];
    [[self view] addSubview:imageview2];
    
    UIImageView *imageview3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"My Feed+View Deal_More button@2X.png"]];
    [imageview3 setFrame:CGRectMake(276, ([[UIScreen mainScreen] bounds].size.height)-64, 29, 29)];
    [[self view] addSubview:imageview3];
    
    UIImageView *imageview4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"My Feed+View Deal_My Feed button@2X.png"]];
    [imageview4 setFrame:CGRectMake(19, ([[UIScreen mainScreen] bounds].size.height)-64, 29, 29)];
    [[self view] addSubview:imageview4];
    
    UIImageView *imageview5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"My Feed+View Deal_Profile button@2X.png"]];
    [imageview5 setFrame:CGRectMake(218, ([[UIScreen mainScreen] bounds].size.height)-64, 29, 29)];
    [[self view] addSubview:imageview5];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(56, ([[UIScreen mainScreen] bounds].size.height)-38, 65, 21)];
    [label setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:11.0]];
    label.text=@"Explore";
    label.backgroundColor=[UIColor clearColor];
    label.textColor = [UIColor colorWithRed:150/255.0 green:0/255.0 blue:180/255.0 alpha:1.0];
    label.textAlignment = NSTextAlignmentCenter;
    [[self view] addSubview:label];
    
    UILabel *label2=[[UILabel alloc]initWithFrame:CGRectMake(258, ([[UIScreen mainScreen] bounds].size.height)-38, 65, 21)];
    [label2 setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:11.0]];
    label2.text=@"More";
    label2.backgroundColor=[UIColor clearColor];
    label2.textColor = [UIColor lightGrayColor];
    label2.textAlignment = NSTextAlignmentCenter;
    [[self view] addSubview:label2];
    
    UILabel *label3=[[UILabel alloc]initWithFrame:CGRectMake(1, ([[UIScreen mainScreen] bounds].size.height)-38, 65, 21)];
    [label3 setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:11.0]];
    label3.text=@"My Feed";
    label3.backgroundColor=[UIColor clearColor];
    label3.textColor = [UIColor lightGrayColor];
    label3.textAlignment = NSTextAlignmentCenter;
    [[self view] addSubview:label3];
    
    UILabel *label4=[[UILabel alloc]initWithFrame:CGRectMake(200, ([[UIScreen mainScreen] bounds].size.height)-38, 65, 21)];
    [label4 setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:11.0]];
    label4.text=@"Profile";
    label4.backgroundColor=[UIColor clearColor];
    label4.textColor = [UIColor lightGrayColor];
    label4.textAlignment = NSTextAlignmentCenter;
    [[self view] addSubview:label4];
    
    
    UIButton *selectDealButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [selectDealButton setTitle:@"" forState:UIControlStateNormal];
    [selectDealButton setImage:[UIImage imageNamed:@"My Feed+View Deal_Add Deal button@2X.png"] forState:UIControlStateNormal];
    selectDealButton.frame=CGRectMake(129, ([[UIScreen mainScreen] bounds].size.height)-75,62,56);
    [selectDealButton addTarget:self action:@selector(showLocalOrOnlineView:) forControlEvents: UIControlEventTouchUpInside];
    selectDealButton.tag=120;
    [[self view] addSubview:selectDealButton];
    
    UIButton *selectDealButton2=[UIButton buttonWithType:UIButtonTypeCustom];
    [selectDealButton2 setTitle:@"" forState:UIControlStateNormal];
    selectDealButton2.frame=CGRectMake(10, ([[UIScreen mainScreen] bounds].size.height)-64,46,45);
    [selectDealButton2 addTarget:self action:@selector(myFeedClicked:) forControlEvents: UIControlEventTouchUpInside];
    [[self view] addSubview:selectDealButton2];
    
    UIButton *selectDealButton3=[UIButton buttonWithType:UIButtonTypeCustom];
    [selectDealButton3 setTitle:@"" forState:UIControlStateNormal];
    selectDealButton3.frame=CGRectMake(65, ([[UIScreen mainScreen] bounds].size.height)-64,46,45);
    [selectDealButton3 addTarget:self action:@selector(exploreClicked:) forControlEvents: UIControlEventTouchUpInside];
    [[self view] addSubview:selectDealButton3];
    
    UIButton *selectDealButton4=[UIButton buttonWithType:UIButtonTypeCustom];
    [selectDealButton4 setTitle:@"" forState:UIControlStateNormal];
    selectDealButton4.frame=CGRectMake(209, ([[UIScreen mainScreen] bounds].size.height)-64,46,45);
    [selectDealButton4 addTarget:self action:@selector(profileClicked:) forControlEvents: UIControlEventTouchUpInside];
    [[self view] addSubview:selectDealButton4];
    
    UIButton *selectDealButton5=[UIButton buttonWithType:UIButtonTypeCustom];
    [selectDealButton5 setTitle:@"" forState:UIControlStateNormal];
    selectDealButton5.frame=CGRectMake(267, ([[UIScreen mainScreen] bounds].size.height)-64,46,45);
    [selectDealButton5 addTarget:self action:@selector(moreClicked:) forControlEvents: UIControlEventTouchUpInside];
    [[self view] addSubview:selectDealButton5];
    
    
    //////////////////////
    //// blue buttons ////
    //////////////////////
    
    UIButton *selectDealButton6=[UIButton buttonWithType:UIButtonTypeCustom];
    [selectDealButton6 setTitle:@"" forState:UIControlStateNormal];
    selectDealButton6.frame=CGRectMake(0, 0,([[UIScreen mainScreen] bounds].size.width),([[UIScreen mainScreen] bounds].size.height-68));
    NSLog(@"%f",[[UIScreen mainScreen] bounds].size.height-44);
    selectDealButton6.tag=100;
    [selectDealButton6 setBackgroundColor:[UIColor whiteColor]];
    [selectDealButton6 addTarget:self action:@selector(hideLocalOrOnlineView) forControlEvents: UIControlEventTouchUpInside];
    selectDealButton6.alpha=0.0;
    [[self view] addSubview:selectDealButton6];
    
    UIButton *selectDealButton9=[UIButton buttonWithType:UIButtonTypeCustom];
    [selectDealButton9 setTitle:@"" forState:UIControlStateNormal];
    selectDealButton9.frame=CGRectMake(0, 0,([[UIScreen mainScreen] bounds].size.width),([[UIScreen mainScreen] bounds].size.height-68));
    selectDealButton9.tag=110;
    [selectDealButton9 setBackgroundColor:[UIColor whiteColor]];
    selectDealButton9.alpha=0.0;
    [[self view] addSubview:selectDealButton9];
    
    UIButton *selectDealButton7=[UIButton buttonWithType:UIButtonTypeCustom];
    [selectDealButton7 setTitle:@"" forState:UIControlStateNormal];
    [selectDealButton7 setImage:[UIImage imageNamed:@"Add Deal (Final)_Local button.png"] forState:UIControlStateNormal];
    selectDealButton7.frame=CGRectMake(45, ([[UIScreen mainScreen] bounds].size.height)-210,100,100);
    selectDealButton7.tag=101;
    [selectDealButton7 addTarget:self action:@selector(goToAddDeal) forControlEvents: UIControlEventTouchUpInside];
    selectDealButton7.alpha=0.0;
    [[self view] addSubview:selectDealButton7];
    
    UIButton *selectDealButton8=[UIButton buttonWithType:UIButtonTypeCustom];
    [selectDealButton8 setTitle:@"" forState:UIControlStateNormal];
    [selectDealButton8 setImage:[UIImage imageNamed:@"Add Deal (Final)_Online button.png"] forState:UIControlStateNormal];
    selectDealButton8.frame=CGRectMake(175, ([[UIScreen mainScreen] bounds].size.height)-210,100,100);
    selectDealButton8.tag=102;
    [selectDealButton8 addTarget:self action:@selector(goToOnline) forControlEvents: UIControlEventTouchUpInside];
    selectDealButton8.alpha=0.0;
    [[self view] addSubview:selectDealButton8];
    
    UILabel *label5=[[UILabel alloc]initWithFrame:CGRectMake(45, ([[UIScreen mainScreen] bounds].size.height)-103, 100, 16)];
    [label5 setFont:[UIFont fontWithName:@"Avenir-Roman" size:16.0]];
    label5.text=@"Local Store";
    label5.backgroundColor=[UIColor clearColor];
    label5.textColor = [UIColor colorWithRed:0/255 green:122/255 blue:255/255 alpha:1.0];
    label5.textAlignment = NSTextAlignmentCenter;
    label5.tag=103;
    label5.alpha=0.0;
    [[self view] addSubview:label5];
    
    UILabel *label6=[[UILabel alloc]initWithFrame:CGRectMake(175, ([[UIScreen mainScreen] bounds].size.height)-103, 100, 16)];
    [label6 setFont:[UIFont fontWithName:@"Avenir-Roman" size:16.0]];
    label6.text=@"The Web";
    label6.backgroundColor=[UIColor clearColor];
    label6.textColor = [UIColor colorWithRed:0/255 green:122/255 blue:255/255 alpha:1.0];
    label6.textAlignment = NSTextAlignmentCenter;
    label6.tag=104;
    label6.alpha=0.0;
    [[self view] addSubview:label6];
    
    UILabel *label7=[[UILabel alloc]initWithFrame:CGRectMake(100, ([[UIScreen mainScreen] bounds].size.height)-236, 320, 16)];
    [label7 setFont:[UIFont fontWithName:@"Avenir-Light" size:16.0]];
    label7.text=@"Add deal from?";
    label7.backgroundColor=[UIColor clearColor];
    label7.textColor = [UIColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:1.0];
    label7.textAlignment = NSTextAlignmentCenter;
    label7.tag=105;
    label7.alpha=0.0;
    [[self view] addSubview:label7];
    
    
}

-(void) myFeedClicked:(id)sender {
    [self deallocMemory];
    UINavigationController *navigationController = self.navigationController;
    NSArray *viewControllers = self.navigationController.viewControllers;
    [navigationController popToViewController:[viewControllers objectAtIndex:2] animated:NO];
}

-(void) exploreClicked:(id)sender {
}

-(void) moreClicked:(id)sender {
    [self deallocMemory];
    MoreViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"more"];
    UINavigationController *navigationController = self.navigationController;
    NSArray *viewControllers = self.navigationController.viewControllers;
    [navigationController popToViewController:[viewControllers objectAtIndex:2] animated:NO];
    [navigationController pushViewController:controller animated:NO];
}

-(void) profileClicked:(id)sender {
    [self deallocMemory];
    ProfileViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"profile"];
    UINavigationController *navigationController = self.navigationController;
    NSArray *viewControllers = self.navigationController.viewControllers;
    [navigationController popToViewController:[viewControllers objectAtIndex:2] animated:NO];
    [navigationController pushViewController:controller animated:NO];
}

-(void) hideLocalOrOnlineView {
    NSLog(@"remove cover");
    UIButton *button1 = (UIButton*)[self.view viewWithTag:100];
    UIButton *button2 = (UIButton*)[self.view viewWithTag:101];
    UIButton *button3 = (UIButton*)[self.view viewWithTag:102];
    UILabel *label1 = (UILabel*)[self.view viewWithTag:103];
    UILabel *label2 = (UILabel*)[self.view viewWithTag:104];
    
    [UIView animateWithDuration:0.5 animations:^{button1.alpha=0.0;
        button2.alpha=0.0;
        button3.alpha=0.0;
        label1.alpha=0.0;
        label2.alpha=0.0;
    }];
    
}

-(void) showLocalOrOnlineView:(id)sender {
    UIButton *button1 = (UIButton*)[self.view viewWithTag:100];
    UIButton *button2 = (UIButton*)[self.view viewWithTag:101];
    UIButton *button3 = (UIButton*)[self.view viewWithTag:102];
    UILabel *label1 = (UILabel*)[self.view viewWithTag:103];
    UILabel *label2 = (UILabel*)[self.view viewWithTag:104];
    
    [UIView animateWithDuration:0.5 animations:^{button1.alpha=0.8;
        button2.alpha=1.0;
        button3.alpha=1.0;
        label1.alpha=1.0;
        label2.alpha=1.0;
    }];
    UIButton *button4 = (UIButton*)[self.view viewWithTag:120];
    [self.view bringSubviewToFront:button4];
   
}

-(void) showWhiteCover {
    UIButton *button1 = (UIButton*)[self.view viewWithTag:110];
    UIButton *button2 = (UIButton*)[self.view viewWithTag:120];
    [self.view bringSubviewToFront:button1];
    [self.view bringSubviewToFront:button2];
    button1.alpha=0.8;
}

-(void) removeWhiteCover {
    NSLog(@"remove white cover");
    UIButton *button1 = (UIButton*)[self.view viewWithTag:110];
    button1.alpha=0.0;
}




@end
