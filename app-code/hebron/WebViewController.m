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
    if ([[request.URL scheme] isEqual:@"passagetells"]) { // TODO && uri contains download.
        NSLog(@"passagetells//");
        NSString *actionsAndParams = request.URL.lastPathComponent;
        NSString *query = request.URL.query;

        
        NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
        NSArray *urlComponents = [query componentsSeparatedByString:@"&"];

        
        for (NSString *keyValuePair in urlComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
            NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
            
            [queryStringDictionary setObject:value forKey:key];
        }


        NSLog(actionsAndParams);
        NSLog(query);
        
        NSLog(@"was path was...");
        if ([actionsAndParams rangeOfString:@"download"].location != NSNotFound) {
                NSLog(@"passagetells///download action");
        }else if([actionsAndParams rangeOfString:@"selectProject"].location != NSNotFound) {
           NSLog(@"passagetells///selectProject action");
            
            //parse the url
            NSString *project_id = (NSString*)[queryStringDictionary objectForKey:@"id"];
            NSString *project_name = (NSString*)[queryStringDictionary objectForKey:@"name"];
            NSLog(project_id);
            NSLog(project_name);
            NSLog(@"was the project id");
            NSMutableString *projectURL = [NSMutableString stringWithString:self.baseURL];
//            [ projectURL appendString:@"/"];
            [projectURL appendString:project_name];
            [projectURL appendString:@"/intro.html"];
            NSLog(projectURL);
            NSString *oururl = [NSString stringWithString:projectURL];
            NSLog(oururl);
            NSURL* url = [NSURL URLWithString: oururl];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
            
            [request setHTTPMethod:@"GET"];
//            [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
//            [request setValue:content_type forHTTPHeaderField:@"Content-Type"];
            [webView loadRequest:request];
            
            
            //TODO save the project id and
//            [[UIApplication sharedApplication] openURL:oururl];
            return NO;
        }
        return NO;
    } else if ([[request.URL scheme] isEqual:@"mailto"] || [[request.URL scheme] isEqual:@"tel"]) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    } else {

        //NSLog(@"shouldStartLoadWithRequest: YES");
        return YES;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //NSLog(webView.request.URL.absoluteString);
    
    // get user id from URL string
    NSLog(@"webViewDidFinishLoad: %@", [webView.request.URL lastPathComponent]);
    
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
