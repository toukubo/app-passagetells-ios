//
//  WebViewController.m
//  passagetells
//
//  Created by HoneyPanda on 8/26/15.
//  Copyright (c) 2015 Daisuke Nakazawa. All rights reserved.
//

#import "WebViewController.h"
#import "MBProgressHUD.h"

@interface WebViewController () <UIWebViewDelegate, MBProgressHUDDelegate>

@property (readwrite) BOOL needToReload;
@property (nonatomic, readwrite) NSString *baseURL;
@property (nonatomic, readwrite) MBProgressHUD *mbLoad;

@end

@implementation WebViewController

@synthesize mbLoad;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // show loading indicator
    mbLoad = [[MBProgressHUD alloc] initWithView:self.view];
    mbLoad.labelText = @"Loading...";
    [self.view addSubview:mbLoad];
    [mbLoad setDelegate:self];
    [mbLoad show:YES];
    
    self.webView.backgroundColor = [UIColor blackColor];
    self.webView.scalesPageToFit = YES;
    self.webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.webView.delegate = self;
    self.webView.scrollView.bounces = NO;
    
    self.baseURL = @"http://passagetellsproject.net/app/";
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.baseURL]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)resume
{
    //NSLog(@"resume: %d", self.needToReload);
    
    if (self.needToReload) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.baseURL]]];
    }
}

-(bool)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"clickedButtonAtIndex: %lu", (unsigned long)buttonIndex);
    if(buttonIndex == 0) {
        // "retry" selected: try to load "Top" page
        return [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.baseURL]]];
    }
    
    // "close" selected
    // XXX: reset
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    
    NSLog(@"shouldStartLoadWithRequest: %@", [request.URL lastPathComponent]);
    if ([[request.URL scheme] isEqual:@"passagetells"] && [[request.URL host] isEqual:@"trigger"]) {
        NSLog(@"passagetells scheme");
        
        // start camera
//        printf(<#const char *restrict, ...#>)
        
        // XXX: no need to release resource on iOS 5
        //[imgPicker release];
        
        return NO;
    } else if ([[request.URL scheme] isEqual:@"jp.studiovoice.evaidios"] && [[request.URL host] isEqual:@"reader"]) {
        // ADD: present a barcode reader that scans from the camera feed
                // TODO: (optional) additional reader configuration here
        
        // EXAMPLE: disable rarely used I2/5 to improve performance

        // present and release the controller

        
        return NO;
    } else if ([[request.URL scheme] isEqual:@"mailto"] || [[request.URL scheme] isEqual:@"tel"]) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    } else {
        if([[request.URL lastPathComponent] isEqualToString:@"PostPublicUserDetailForCard.do"] ||
           [[request.URL lastPathComponent] isEqualToString:@"exchange.jsp"] ||
           [[request.URL lastPathComponent] isEqualToString:@"ShowPublicUserForExchanges.do"] ||
           [[request.URL lastPathComponent] isEqualToString:@"ShowPublicUserForCard.do"]){
            //            NSLog(@"Showing our Ad there");

        }
        else{
            //            NSLog(@"Hide or not show Ad here");

        }
        //NSLog(@"shouldStartLoadWithRequest: YES");
        return YES;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //NSLog(webView.request.URL.absoluteString);
    
    // get user id from URL string
    NSLog(@"webViewDidFinishLoad: %@", [webView.request.URL lastPathComponent]);
    if([[webView.request.URL lastPathComponent] isEqualToString:@"ShowPublicUser.do"]){

    }
//    NSDictionary *params = [webView.request.URL queryAsDictionary];
//    self.myID = [params objectForKey:@"id"];
    //NSLog(self.myID);
    
    // hide loading indicator
    if (mbLoad != nil && !mbLoad.isHidden) {
        NSLog(@"hide loading indicator");
        [mbLoad hide:YES];
    }
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*) error {
    //NSLog(@"didFailLoadWithError");
    
    self.needToReload = YES;
    
    NSInteger code = [error code];
    if (code == NSURLErrorCancelled) {
        // ignore cancel by user
        return;
    }
    
    NSString *desc = @"通信できませんでした。\n再度お試しください。";
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Eva ID" message:desc delegate:self
                                          cancelButtonTitle:@"Retry" otherButtonTitles:@"Close", nil];
    [alert show];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [mbLoad removeFromSuperview];
    mbLoad = nil;
}

@end
