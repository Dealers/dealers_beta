//
//  OnlineViewController.m
//  Dealers-testbeta
//
//  Created by itzik berrebi on 2/12/14.
//
//

#import "OnlineViewController.h"
#import "AppDelegate.h"
#import "OptionalaftergoogleplaceViewController.h"

@interface OnlineViewController ()

@end

@implementation OnlineViewController

- (void)viewDidLoad
{
    [self.UrlBar setDelegate:self];
    [self.UrlBar setReturnKeyType:UIReturnKeyDone];
    [self.UrlBar addTarget:self action:@selector(UrlBar) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self initView];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void) initView {
    self.UrlBar.text=@"www.dealers.co.il";
    NSString *Urlstring=[NSString stringWithFormat:@"http://www.dealers.co.il"];
    [[Urlstring stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:Urlstring];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];

}
- (void)didReceiveMemoryWarning
{
    //[self deallocOnlineView];
    [self.navigationController popViewControllerAnimated:YES];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    NSString *Urlstring=[NSString stringWithFormat:@"http://%@",self.UrlBar.text];
    [[Urlstring stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:Urlstring];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error : %@",error);
}

- (IBAction) webViewGoBack:(id)sender
{
    if ([_webView canGoBack]) [_webView goBack];
}

- (IBAction) webViewGoForward:(id)sender
{
    if ([_webView canGoForward]) [_webView goForward];
}

- (IBAction) ReturnButton:(id)sender{
    [self deallocOnlineView];
    UINavigationController * navigationController = self.navigationController;
    NSArray *viewControllers = self.navigationController.viewControllers;
    [navigationController popToViewController:[viewControllers objectAtIndex:2] animated:NO];
}

-(void) deallocOnlineView {
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    [_webView stringByEvaluatingJavaScriptFromString:@"document.open();document.close()"];
    [_webView stopLoading];
    _webView.delegate=nil;
    _webView=nil;
    static NSCache *_cache = nil;
    [_cache removeAllObjects];
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    [_webView removeFromSuperview];
}

- (IBAction) DealitButton:(id)sender {
    [self.UrlBar resignFirstResponder];
    AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    app.previousViewControllerAddDeal=@"online";
    OptionalaftergoogleplaceViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Optional"];
    controller.storeName=@"online";
    controller.segcategory=@"Online";
    [self.navigationController pushViewController:controller animated:YES];

}

@end