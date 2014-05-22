//
//  ViewonedealViewController.m
//  GooglePlaces
//
//  Created by itzik berrebi on 9/26/13.
//
//

#import "ViewonedealViewController.h"
#import "MoreViewController.h"
#import "ProfileViewController.h"
#import "ExploretableViewController.h"
#import "AppDelegate.h"
#import "TableViewController.h"
#import "LikesCell.h"
#import <QuartzCore/QuartzCore.h>
#import "OnlineViewController.h"

#define GAP 12

@interface ViewonedealViewController ()

@end

@implementation ViewonedealViewController
@synthesize scroll;
@synthesize titlelabel;
@synthesize storelabel;
@synthesize categorylabel;
@synthesize pricelabel;
@synthesize discountlabel;
@synthesize expirelabel;
@synthesize descriptionlabel;
@synthesize likelabel;
@synthesize commentlabel;
@synthesize productimage;
@synthesize clientimage,ReturnButton,ReturnButtonFull;

-(void) startLoadingUploadImage {
    _loadingImage.animationImages = [NSArray arrayWithObjects:
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
    _loadingImage.animationDuration = 0.3;
    [_loadingImage startAnimating];
    [UIView animateWithDuration:0.2 animations:^{_loadingImage.alpha=1.0; _loadingImage.transform =CGAffineTransformMakeScale(0,0);
        _loadingImage.transform =CGAffineTransformMakeScale(1,1);}];
}

-(void) maskUserProfileImage {
    CALayer *mask = [CALayer layer];
    mask.contents=(id)[[UIImage imageNamed:@"Registration_Email button.png"]CGImage];
    mask.frame = CGRectMake(0, 0, 60, 60);
    clientimage.layer.mask = mask;
    clientimage.layer.masksToBounds = YES;
}

-(void) setViewUnderDealParameters
{
    
    CGRect frame2 = self.SecondView.frame;
    frame2.origin.y = 7+lowestYPoint;
    self.SecondView.frame = frame2;
    lowestYPoint =(CGRectGetMaxY(_SecondView.frame));

    if (![likelabel isEqualToString:@"0"]) {
        CGRect frame = _likesandshareView.frame;
        frame.origin.y = 15 + lowestYPoint;
        _likesandshareView.frame = frame;
        NSString *likesCountPrefix=[NSString stringWithFormat:@"%@",likelabel];
        NSString *likesCountSuffix=@"  people like this deal";
        NSString *likeCount=[likesCountPrefix stringByAppendingString:likesCountSuffix];
        _likesCountLabel.text=likeCount;
        
        NSString *shareCountPrefix=[NSString stringWithFormat:@"%@",likelabel];
        NSString *shareCountSuffix=@"  people shared this deal";
        NSString *shareCount=[shareCountPrefix stringByAppendingString:shareCountSuffix];
        _shreCountLabel.text=shareCount;
        lowestYPoint=(CGRectGetMaxY(_likesandshareView.frame));
    } else {
        _likesandshareView.hidden=YES;
    }
    
    frame2 = _buttonsUnderDealerImage.frame;
    frame2.origin.y = 7+lowestYPoint;
    _buttonsUnderDealerImage.frame = frame2;

    
}

-(void) setScrollSize //ok
{
    [scroll setScrollEnabled:YES];
    int BottumCoordinate=CGRectGetMaxY(_buttonsUnderDealerImage.frame)+80;
    [scroll setContentSize:((CGSizeMake(320, BottumCoordinate)))];
}

-(NSString *) currencySymbol : (NSString *) sign
{
    if ([sign isEqualToString:@"1"]) {
        sign=@"₪";
    }
    if ([sign isEqualToString:@"2"]) {
        sign=@"$";
    }
    if ([sign isEqualToString:@"3"]) {
        sign=@"£";
    }
    return sign;
}

-(void) locateIconsInPlace {
    
    [self maskUserProfileImage];
    flag = NO;
    int offset;
    if (numofpics==0) {
        offset=10;
    } else offset=184;
    
    self.TitleIcon.frame = CGRectMake(10, offset, self.TitleIcon.frame.size.width, self.TitleIcon.frame.size.height);
    titlelabel.frame = CGRectMake(50, offset+4, titlelabel.frame.size.width, titlelabel.frame.size.height);
    titlelabel.numberOfLines=0;
    [titlelabel sizeToFit];
    
    lowestYPoint=(CGRectGetMaxY(self.TitleIcon.frame) > CGRectGetMaxY(titlelabel.frame)) ? CGRectGetMaxY(self.TitleIcon.frame) : CGRectGetMaxY(titlelabel.frame);
    
    self.StoreIcon.frame = CGRectMake(10, lowestYPoint + GAP, self.StoreIcon.frame.size.width, self.StoreIcon.frame.size.height);
    storelabel.frame = CGRectMake(50, lowestYPoint+3+GAP, storelabel.frame.size.width, storelabel.frame.size.height);
    
    if ([_localoronlineLabelFromMyFeeds isEqualToString:@"online"]) {
        _urlSiteButton.frame = CGRectMake(50, lowestYPoint+3+GAP, storelabel.frame.size.width, storelabel.frame.size.height);
    } else _urlSiteButton.hidden=YES;

    lowestYPoint=(CGRectGetMaxY(self.StoreIcon.frame) > CGRectGetMaxY(storelabel.frame)) ? CGRectGetMaxY(self.StoreIcon.frame) : CGRectGetMaxY(storelabel.frame);
    
    if ((![categorylabel.text isEqualToString:@""]) || (![categorylabel.text isEqualToString:@"No Category"])) {
        self.CategoryIcon.frame = CGRectMake(10, lowestYPoint + GAP, self.CategoryIcon.frame.size.width, self.CategoryIcon.frame.size.height);
        categorylabel.frame = CGRectMake(50, lowestYPoint+3+GAP, categorylabel.frame.size.width, categorylabel.frame.size.height);
        lowestYPoint=(CGRectGetMaxY(self.CategoryIcon.frame) > CGRectGetMaxY(categorylabel.frame)) ? CGRectGetMaxY(self.CategoryIcon.frame) : CGRectGetMaxY(categorylabel.frame);
    } else {
        categorylabel.hidden=YES;
        self.CategoryIcon.hidden=YES;
    }
    
    maxXPoint=50;
    
    if (![pricelabel.text isEqualToString:@"0"]) {
        pricelabel.text = [pricelabel.text stringByAppendingString:[self currencySymbol:self.signLabelFromMyFeeds]];
        [pricelabel sizeToFit];
        self.PriceIcon.frame = CGRectMake(10, lowestYPoint + GAP, self.PriceIcon.frame.size.width, self.PriceIcon.frame.size.height);
        pricelabel.frame = CGRectMake(maxXPoint, lowestYPoint+3+GAP, pricelabel.frame.size.width, pricelabel.frame.size.height);
        flag = YES;
        maxXPoint= CGRectGetMaxX (pricelabel.frame)+20;
    } else {
        pricelabel.hidden=YES;
    }
    
    if (![discountlabel.text isEqualToString:@"0"]) {
        discountlabel.text = [discountlabel.text stringByAppendingString:@"%"];
        self.PriceIcon.frame = CGRectMake(10, lowestYPoint + GAP, self.PriceIcon.frame.size.width, self.PriceIcon.frame.size.height);
        discountlabel.frame = CGRectMake(maxXPoint, lowestYPoint+3+GAP, discountlabel.frame.size.width, discountlabel.frame.size.height);
        lowestYPoint=(CGRectGetMaxY(self.PriceIcon.frame) > CGRectGetMaxY(discountlabel.frame)) ? CGRectGetMaxY(self.PriceIcon.frame) : CGRectGetMaxY(discountlabel.frame);
    } else {
        discountlabel.hidden=YES;
        if (![pricelabel.text isEqualToString:@"0"]) {
            lowestYPoint=(CGRectGetMaxY(self.PriceIcon.frame) > CGRectGetMaxY(pricelabel.frame)) ? CGRectGetMaxY(self.PriceIcon.frame) : CGRectGetMaxY(pricelabel.frame);
        }
    }
    
    
    if ((pricelabel.hidden == YES) && (discountlabel.hidden == YES)) self.PriceIcon.hidden=YES;
    
    NSLog(@"expire=%@",expirelabel.text);
    if ((![expirelabel.text isEqualToString:@"0000-00-00 00:00:00"])&&([expirelabel.text length]>0)) {
        self.ExpireIcon.frame = CGRectMake(10, lowestYPoint + GAP, self.ExpireIcon.frame.size.width, self.ExpireIcon.frame.size.height);
        expirelabel.frame = CGRectMake(50, lowestYPoint+3+GAP, expirelabel.frame.size.width, expirelabel.frame.size.height);
        lowestYPoint=(CGRectGetMaxY(self.ExpireIcon.frame) > CGRectGetMaxY(expirelabel.frame)) ? CGRectGetMaxY(self.ExpireIcon.frame) : CGRectGetMaxY(expirelabel.frame);
    } else {
        expirelabel.hidden=YES;
        self.ExpireIcon.hidden=YES;
    }
    
    
    if (!([descriptionlabel.text length]==0)) {
        descriptionlabel.numberOfLines=0;
        [descriptionlabel sizeToFit];
        self.DescriptionIcon.frame = CGRectMake(10, lowestYPoint + GAP, self.DescriptionIcon.frame.size.width, self.DescriptionIcon.frame.size.height);
        descriptionlabel.frame = CGRectMake(50, lowestYPoint+3+GAP, descriptionlabel.frame.size.width, descriptionlabel.frame.size.height);
        lowestYPoint=(CGRectGetMaxY(self.DescriptionIcon.frame) > CGRectGetMaxY(descriptionlabel.frame)) ? CGRectGetMaxY(self.DescriptionIcon.frame) : CGRectGetMaxY(descriptionlabel.frame);
    } else {
        descriptionlabel.hidden=YES;
        self.DescriptionIcon.hidden=YES;
    }
    
    [self setViewUnderDealParameters];
    [self setScrollSize];
}

-(void) loadImageFromUrl {
    if (numofpics!=0) {
        NSString *FindURL = [NSString stringWithFormat:@"http://www.dealers.co.il/setLikeToDeal.php?Indicator=bringphotos&Dealid=%@",_dealidLabelFromMyFeeds];
        NSLog(@"%d",numofpics);
        NSData *URLData = [NSData dataWithContentsOfURL:[NSURL URLWithString:FindURL]];
        NSString *DataResult = [[NSString alloc] initWithData:URLData encoding:NSUTF8StringEncoding];
        NSArray *DataArray = [DataResult componentsSeparatedByString:@"^"];
        
       /* if (numofpics==1) {
            _urlImage = [NSString stringWithFormat:@"http://www.dealers.co.il/%@.jpg",self.photoIdLabelFromMyFeeds];
            _tempImage=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_urlImage]]];
        }*/
        if (numofpics==2) {
            _urlImage = [NSString stringWithFormat:@"http://www.dealers.co.il/%@.jpg",self.photoIdLabelFromMyFeeds];
            _urlImage2 = [NSString stringWithFormat:@"http://www.dealers.co.il/%@.jpg",DataArray[0]];
            //_tempImage=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_urlImage]]];
            _tempImage2=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_urlImage2]]];
            
        }
        if (numofpics==3) {
            _urlImage = [NSString stringWithFormat:@"http://www.dealers.co.il/%@.jpg",self.photoIdLabelFromMyFeeds];
            _urlImage2 = [NSString stringWithFormat:@"http://www.dealers.co.il/%@.jpg",DataArray[0]];
            _urlImage3 = [NSString stringWithFormat:@"http://www.dealers.co.il/%@.jpg",DataArray[1]];
           // _tempImage=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_urlImage]]];
            _tempImage2=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_urlImage2]]];
            _tempImage3=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_urlImage3]]];
            
            
        }
        if (numofpics==4) {
            _urlImage = [NSString stringWithFormat:@"http://www.dealers.co.il/%@.jpg",self.photoIdLabelFromMyFeeds];
            _urlImage2 = [NSString stringWithFormat:@"http://www.dealers.co.il/%@.jpg",DataArray[0]];
            _urlImage3 = [NSString stringWithFormat:@"http://www.dealers.co.il/%@.jpg",DataArray[1]];
            _urlImage4 = [NSString stringWithFormat:@"http://www.dealers.co.il/%@.jpg",DataArray[2]];
        //    _tempImage=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_urlImage]]];
            _tempImage2=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_urlImage2]]];
            _tempImage3=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_urlImage3]]];
            _tempImage4=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_urlImage4]]];
            
        }
    }
    
}

-(void) loadImage {
    if (numofpics==0) {
        self.captureImage.image=[UIImage imageNamed:@"nodeal.jpeg"];
    }
    if (numofpics==1) {
       // self.captureImage.image = _tempImage;
    }
    if (numofpics==2) {
       // self.captureImage.image = _tempImage;
        self.captureImage2.image = _tempImage2;
    }
    if (numofpics==3) {
       // self.captureImage.image = _tempImage;
        self.captureImage2.image = _tempImage2;
        self.captureImage3.image = _tempImage3;
    }
    if (numofpics==4) {
       // self.captureImage.image = _tempImage;
        self.captureImage2.image = _tempImage2;
        self.captureImage3.image = _tempImage3;
        self.captureImage4.image = _tempImage4;
    }
    _tempImage=nil;
    _tempImage2=nil;
    _tempImage3=nil;
    _tempImage4=nil;
    
    [_loadingImage stopAnimating];
    _loadingImage.hidden=YES;
}

-(void) loadVarsFromDeal{
    titlelabel.text = self.titleLabelFromMyFeeds;
    storelabel.text = self.storeLabelFromMyFeeds;
    categorylabel.text = self.categoryLabelFromMyFeeds;
    pricelabel.text = self.priceLabelFromMyFeeds;
    discountlabel.text = self.discountLabelFromMyFeeds;
    expirelabel.text = self.expireLabelFromMyFeeds;
    if (![self.expireLabelFromMyFeeds isEqualToString:@""]) {
    NSString *expirePrefix = @"Expires on ";
    NSString *expireSuffix = [NSString stringWithFormat:@"%@",expirelabel.text];
    expirePrefix = [expirePrefix stringByAppendingString:expireSuffix];
    expirelabel.text=expirePrefix;
    }
    descriptionlabel.text = self.descriptionLabelFromMyFeeds;
    likelabel = self.likeLabelFromMyFeeds;
    commentlabel = self.commentLabelFromMyFeeds;
    LikeOrUnlike=TRUE;
}

-(int) numOfPicturesInTheDeal {
    NSString *FindURL = [NSString stringWithFormat:@"http://www.dealers.co.il/setLikeToDeal.php?Indicator=howmanyphotos&Dealid=%@",_dealidLabelFromMyFeeds];
    NSData *URLData = [NSData dataWithContentsOfURL:[NSURL URLWithString:FindURL]];
    NSString *DataResult = [[NSString alloc] initWithData:URLData encoding:NSUTF8StringEncoding];
    return [DataResult intValue];
}

-(void) dealerViewInitialize {
    dispatch_queue_t queue = dispatch_queue_create("com.MyQueue2", NULL);
    dispatch_async(queue, ^{
        // Do some computation here.
        NSString *FindURL = [NSString stringWithFormat:@"http://www.dealers.co.il/setLikeToDeal.php?Indicator=whodiduploadthedeal&Dealid=%@",_dealidLabelFromMyFeeds];
        NSData *URLData = [NSData dataWithContentsOfURL:[NSURL URLWithString:FindURL]];
        NSString *DataResult = [[NSString alloc] initWithData:URLData encoding:NSUTF8StringEncoding];
        NSArray *DataArray = [DataResult componentsSeparatedByString:@"^"];
        NSString *urlImage = [NSString stringWithFormat:@"http://www.dealers.co.il/%@.jpg",[DataArray objectAtIndex:2]];
        // Update UI after computation.
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI on the main thread.
            _uploadDateLabel.text=[DataArray objectAtIndex:0];
            _dealersNameLabel.text=[DataArray objectAtIndex:1];
            _dealerUploadDealID=[DataArray objectAtIndex:3];
            self.clientimage.image =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlImage]]];
        });
    });
    
}

- (void)viewDidLoad //ok
{
    self.scroll.frame=CGRectMake(0, 44, 320, [[UIScreen mainScreen] bounds].size.height-44);
    _tableViewLikes.hidden=YES;
    
    if ([_isShoetCell isEqualToString:@"yes"]) {
        numofpics=0;
        self.cameraScrollView.hidden=YES;
    } else {
        _captureImage.image=_tempImage;
        numofpics=1;
    }
    
    if ([_likeornotLabelFromMyFeeds isEqualToString:@"yes"]) {
        _LikeButton.enabled=NO;
        [_LikeButton setImage:[UIImage imageNamed:@"My Feed+View Deal (final)_Like button (selected).png"] forState:UIControlStateNormal];
    }
    
    viewDidApear=YES;
    cellNumberInScrollView=0;
    likesView = NO;
    
    [self tapBarSet];
    [self loadVarsFromDeal];
    [self locateIconsInPlace];
    
    [super viewDidLoad];

}

-(void)viewDidAppear:(BOOL)animated //ok
{
    if (viewDidApear) {
        
        if ([_isShoetCell isEqualToString:@"no"]) {
            numofpics=[self numOfPicturesInTheDeal];
            [self startLoadingUploadImage];
            dispatch_queue_t queue = dispatch_queue_create("com.MyQueue", NULL);
            dispatch_async(queue, ^{
                // Do some computation here.
                [self loadImageFromUrl];
                // Update UI after computation.
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the UI on the main thread.
                    [self loadImage];
                });
            });
        }
        
        [self dealerViewInitialize];
        if (numofpics>=2) {
            _pageControl.hidden=NO;
        } else _pageControl.hidden=YES;
        self.pageControl.numberOfPages=numofpics;
        _ViewLikes.hidden=YES;
        [self.cameraScrollView setContentSize:((CGSizeMake(320*numofpics, 155)))];
        [self.cameraScrollView setScrollEnabled:YES];
        viewDidApear=NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (IBAction)ReturnButtonAction:(id)sender {
    
    if (likesView) {
        _ViewLikes.hidden=YES;
        likesView=NO;
    } else {
        //AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        //app.AfterAddDeal=@"yes";
        ReturnButtonFull.alpha=1.0;
        ReturnButton.alpha=0.0;
        [UIView animateWithDuration:0.2 animations:^{self.ReturnButtonFull.alpha=0.0;}];
        [UIView animateWithDuration:0.2 animations:^{self.ReturnButton.alpha=1.0;}];
        UINavigationController *navigationController = self.navigationController;
        [navigationController popViewControllerAnimated:YES];
    }
}


- (IBAction)LikeButtonAction:(id)sender {
    
    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if ([_likeornotLabelFromMyFeeds isEqualToString:@"no"]) {
        _LikeButton.enabled=NO;
        _likeornotLabelFromMyFeeds=@"yes";
        [self.LikeButton setImage:[UIImage imageNamed:@"My Feed+View Deal (final)_Like button (selected).png"] forState:UIControlStateNormal];
        int IntLike = [likelabel intValue];
        IntLike++;
        likelabel=[NSString stringWithFormat:@"%d",IntLike];
        NSString *url = [NSString stringWithFormat:@"http://www.dealers.co.il/setLikeToDeal.php?Userid=%@&Indicator=%@&Dealid=%@",app.UserID,@"updatelikestables",_dealidLabelFromMyFeeds];
        NSLog(@"url updatin after like: %@", url);
        NSData *URLData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        NSString *DataResult = [[NSString alloc] initWithData:URLData encoding:NSUTF8StringEncoding];
    }
}

-(void) loadDataFromDB {
    NSString *url = [NSString stringWithFormat:@"http://www.dealers.co.il/setLikeToDeal.php?Indicator=%@&Dealid=%@",@"wholikesthedeal",_dealidLabelFromMyFeeds];
    NSData *URLData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    NSString *DataResult = [[NSString alloc] initWithData:URLData encoding:NSUTF8StringEncoding];
    _DealersDataWhoLikesTheDealArray = [DataResult componentsSeparatedByString:@"."];
    
    _dealersNameArray = [[NSMutableArray alloc]init];
    _dealersPhotoArray = [[NSMutableArray alloc]init];
    _dealersPhotoDataArray = [[NSMutableArray alloc]init];
    _dealersidArray = [[NSMutableArray alloc]init];
    
    
    for (int i=0; i<([[_DealersDataWhoLikesTheDealArray copy]count]-1); i=i+3) {
        [_dealersidArray addObject:[_DealersDataWhoLikesTheDealArray objectAtIndex:i]];
        
        [_dealersNameArray addObject:[_DealersDataWhoLikesTheDealArray objectAtIndex:i+1]];
        [_dealersPhotoArray addObject:[_DealersDataWhoLikesTheDealArray objectAtIndex:i+2]];
        [_dealersPhotoDataArray addObject:@"0"];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView==_tableViewLikes) {
        if ([_dealersNameArray count] == 0) {
            return 0;
        }
        return [_dealersNameArray count];
    } else return [_dealersNameArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LikesCell *Cell=nil;
    if (tableView==_tableViewLikes) {
        
        static NSString *CellIdentifier = @"likescell";
        Cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!Cell) Cell = [[LikesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        if (indexPath.row<[_dealersNameArray count]) {
            Cell.dealerName.text = [_dealersNameArray objectAtIndex:indexPath.row];
        } else Cell.dealerName.text = @"Unknown";
        
        if ([[_dealersPhotoDataArray objectAtIndex:indexPath.row] isEqual:@"0"]) {
            dispatch_queue_t queue = dispatch_queue_create("com.MyQueue3", NULL);
            dispatch_async(queue, ^{
                // Do some computation here.
                NSString *FindURL = [NSString stringWithFormat:@"http://www.dealers.co.il/%@.jpg",[_dealersPhotoArray objectAtIndex:indexPath.row]];
                NSData *URLData = [NSData dataWithContentsOfURL:[NSURL URLWithString:FindURL]];
                // Update UI after computation.
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the UI on the main thread.
                    UIImage *image = [UIImage imageWithData:URLData];
                    [_dealersPhotoDataArray replaceObjectAtIndex:indexPath.row withObject:image];
                    Cell.dealerImage.image = image;
                    CALayer *mask = [CALayer layer];
                    mask.contents=(id)[[UIImage imageNamed:@"My Feed+View Deal (final)_Deal Pic mask.png"]CGImage];
                    mask.frame = CGRectMake(0, 0, 40, 40);
                    Cell.dealerImage.layer.mask = mask;
                    Cell.dealerImage.layer.masksToBounds = YES;
                    
                    [_tableViewLikes beginUpdates];
                    [_tableViewLikes reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
                    [_tableViewLikes endUpdates];
                });
            });
            
        } else {
            Cell.dealerImage.image = [_dealersPhotoDataArray objectAtIndex:indexPath.row];
            CALayer *mask = [CALayer layer];
            mask.contents=(id)[[UIImage imageNamed:@"My Feed+View Deal (final)_Deal Pic mask.png"]CGImage];
            mask.frame = CGRectMake(0, 0, 40, 40);
            Cell.dealerImage.layer.mask = mask;
            Cell.dealerImage.layer.masksToBounds = YES;
        }
        
    }
    return Cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableViewLikes deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"likescell"]) {
        NSIndexPath *indexpath = [_tableViewLikes indexPathForSelectedRow];
        NSString *string;
        string = [_dealersidArray objectAtIndex:indexpath.row];
        [[segue destinationViewController] setDealerId:string];
        [[segue destinationViewController] setDidComeFromLikesTable:@"yes"];
        
    }
}


- (IBAction)whoLikesTheDeal:(id)sender{
    
    if (![likelabel isEqualToString:@"0"]) {
        likesView=YES;
        dispatch_queue_t queue = dispatch_queue_create("com.MyQueue4", NULL);
        dispatch_async(queue, ^{
            // Do some computation here.
            [self loadDataFromDB];
            // Update UI after computation.
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI on the main thread.
                _ViewLikes.hidden=NO;
                [_tableViewLikes reloadData];
            });
        });
    }
}

- (IBAction)CommentButtonAction:(id)sender {
}

- (IBAction)ShareButtonAction:(id)sender {
    NSString *name = @"Dealers";
    NSArray *activityItems = @[name];
    UIActivityViewController *acv = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:acv animated:YES completion:nil];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = self.cameraScrollView.frame.size.width;
    currentpage = floor((self.cameraScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage=currentpage;
}

-(void) deallocMemory {
    self.titleLabelFromMyFeeds=nil;
    self.storeLabelFromMyFeeds=nil;
    self.categoryLabelFromMyFeeds=nil;
    self.priceLabelFromMyFeeds=nil;
    self.discountLabelFromMyFeeds=nil;
    self.expireLabelFromMyFeeds=nil;
    self.descriptionLabelFromMyFeeds=nil;
    self.photoIdLabelFromMyFeeds=nil;
    self.likeLabelFromMyFeeds=nil;
    self.commentLabelFromMyFeeds=nil;
    self.clientIdLabelFromMyFeeds=nil;
    self.signLabelFromMyFeeds=nil;
    self.DealersDataWhoLikesTheDealArray=nil;
    NSLog(@"dealloc viewdeal");
}

-(void)viewDidDisappear:(BOOL)animated {
    /*
     self.titleLabelFromMyFeeds=nil;
     self.storeLabelFromMyFeeds=nil;
     self.categoryLabelFromMyFeeds=nil;
     self.priceLabelFromMyFeeds=nil;
     self.discountLabelFromMyFeeds=nil;
     self.expireLabelFromMyFeeds=nil;
     self.descriptionLabelFromMyFeeds=nil;
     self.photoIdLabelFromMyFeeds=nil;
     self.likeLabelFromMyFeeds=nil;
     self.commentLabelFromMyFeeds=nil;
     self.clientIdLabelFromMyFeeds=nil;
     self.signLabelFromMyFeeds=nil;
     NSArray *viewsToRemove = [self.view subviews];
     for (UIView *v in viewsToRemove) {
     [v removeFromSuperview];
     }
     [self.view removeFromSuperview];
     self.view=nil;
     NSLog(@"dealloc viewdeal");*/
}

- (IBAction)dealerProfileButtonClicked:(id)sender {
    ProfileViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"profile"];
    controller.dealerId=_dealerUploadDealID;
    controller.didComeFromLikesTable=@"yes";
    UINavigationController *navigationController = self.navigationController;
    [navigationController pushViewController:controller animated:YES];
}

- (IBAction)urlSiteButtonClicked:(id)sender {
    NSString *FindURL = [NSString stringWithFormat:@"http://www.dealers.co.il/setLikeToDeal.php?Indicator=bringurlsite&Dealid=%@",_dealidLabelFromMyFeeds];
    NSData *URLData = [NSData dataWithContentsOfURL:[NSURL URLWithString:FindURL]];
    NSString *DataResult = [[NSString alloc] initWithData:URLData encoding:NSUTF8StringEncoding];
    DataResult = [@"http://" stringByAppendingString:DataResult];
    NSLog(@"%@",DataResult);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:DataResult]];

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
    
    UIImageView *imageview2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"My Feed+View Deal_Explore button@2X.png"]];
    [imageview2 setFrame:CGRectMake(74, ([[UIScreen mainScreen] bounds].size.height)-64, 29, 29)];
    [[self view] addSubview:imageview2];
    
    UIImageView *imageview3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"My Feed+View Deal_More button@2X.png"]];
    [imageview3 setFrame:CGRectMake(276, ([[UIScreen mainScreen] bounds].size.height)-64, 29, 29)];
    [[self view] addSubview:imageview3];
    
    UIImageView *imageview4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"My Feed+View Deal_My Feed button(selected)@2X.png"]];
    [imageview4 setFrame:CGRectMake(19, ([[UIScreen mainScreen] bounds].size.height)-64, 29, 29)];
    [[self view] addSubview:imageview4];
    
    UIImageView *imageview5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"My Feed+View Deal_Profile button@2X.png"]];
    [imageview5 setFrame:CGRectMake(218, ([[UIScreen mainScreen] bounds].size.height)-64, 29, 29)];
    [[self view] addSubview:imageview5];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(56, ([[UIScreen mainScreen] bounds].size.height)-38, 65, 21)];
    [label setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:11.0]];
    label.text=@"Explore";
    label.backgroundColor=[UIColor clearColor];
    label.textColor = [UIColor lightGrayColor];
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
    label3.textColor = [UIColor colorWithRed:150/255.0 green:0/255.0 blue:180/255.0 alpha:1.0];
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
    
    //    UIButton *selectDealButton9=[UIButton buttonWithType:UIButtonTypeCustom];
    //    [selectDealButton9 setTitle:@"" forState:UIControlStateNormal];
    //    selectDealButton9.frame=CGRectMake(0, 0,([[UIScreen mainScreen] bounds].size.width),([[UIScreen mainScreen] bounds].size.height-68));
    //    selectDealButton9.tag=110;
    //    [selectDealButton9 setBackgroundColor:[UIColor whiteColor]];
    //    selectDealButton9.alpha=0.0;
    //    [[self view] addSubview:selectDealButton9];
    
    UIButton *selectDealButton7=[UIButton buttonWithType:UIButtonTypeCustom];
    [selectDealButton7 setTitle:@"" forState:UIControlStateNormal];
    [selectDealButton7 setImage:[UIImage imageNamed:@"Add Deal (Final)_Local button.png"] forState:UIControlStateNormal];
    selectDealButton7.frame=CGRectMake(55, ([[UIScreen mainScreen] bounds].size.height)-210,90,90);
    selectDealButton7.tag=101;
    [selectDealButton7 addTarget:self action:@selector(goToAddDeal) forControlEvents: UIControlEventTouchUpInside];
    selectDealButton7.alpha=0.0;
    [[self view] addSubview:selectDealButton7];
    
    UIButton *selectDealButton8=[UIButton buttonWithType:UIButtonTypeCustom];
    [selectDealButton8 setTitle:@"" forState:UIControlStateNormal];
    [selectDealButton8 setImage:[UIImage imageNamed:@"Add Deal (Final)_Online button.png"] forState:UIControlStateNormal];
    selectDealButton8.frame=CGRectMake(175, ([[UIScreen mainScreen] bounds].size.height)-210,90,90);
    selectDealButton8.tag=102;
    [selectDealButton8 addTarget:self action:@selector(goToOnline) forControlEvents: UIControlEventTouchUpInside];
    selectDealButton8.alpha=0.0;
    [[self view] addSubview:selectDealButton8];
    
    UILabel *label5=[[UILabel alloc]initWithFrame:CGRectMake(55, ([[UIScreen mainScreen] bounds].size.height)-110, 90, 16)];
    [label5 setFont:[UIFont fontWithName:@"Avenir-Roman" size:16.0]];
    label5.text=@"Local Store";
    label5.backgroundColor=[UIColor clearColor];
    label5.textColor = [UIColor colorWithRed:0/255 green:122/255 blue:255/255 alpha:1.0];
    label5.textAlignment = NSTextAlignmentCenter;
    label5.tag=103;
    label5.alpha=0.0;
    [[self view] addSubview:label5];
    
    UILabel *label6=[[UILabel alloc]initWithFrame:CGRectMake(175, ([[UIScreen mainScreen] bounds].size.height)-110, 90, 16)];
    [label6 setFont:[UIFont fontWithName:@"Avenir-Roman" size:16.0]];
    label6.text=@"The Web";
    label6.backgroundColor=[UIColor clearColor];
    label6.textColor = [UIColor colorWithRed:0/255 green:122/255 blue:255/255 alpha:1.0];
    label6.textAlignment = NSTextAlignmentCenter;
    label6.tag=104;
    label6.alpha=0.0;
    [[self view] addSubview:label6];
    
    UILabel *label7=[[UILabel alloc]initWithFrame:CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height)-246, 320, 22)];
    [label7 setFont:[UIFont fontWithName:@"Avenir-Light" size:22.0]];
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
    [self deallocMemory];
    ExploretableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"explore"];
    UINavigationController *navigationController = self.navigationController;
    NSArray *viewControllers = self.navigationController.viewControllers;
    [navigationController popToViewController:[viewControllers objectAtIndex:2] animated:NO];
    [navigationController pushViewController:controller animated:NO];
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
    UIButton *button4 = (UIButton*)[self.view viewWithTag:120];
    [self.view bringSubviewToFront:button4];

    [UIView animateWithDuration:0.5 animations:^{button1.alpha=0.8;
        button2.alpha=1.0;
        button3.alpha=1.0;
        label1.alpha=1.0;
        label2.alpha=1.0;
    }];
    
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
