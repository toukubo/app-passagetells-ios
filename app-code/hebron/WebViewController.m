//
//  WebViewController.m
//  passagetells
//
//  Created by HoneyPanda on 8/26/15.
//  Copyright (c) 2015 Daisuke Nakazawa. All rights reserved.
//

#import "WebViewController.h"
#import "passagetells-Swift.h"

#import "Common.h"

@interface WebViewController () <UIWebViewDelegate, MBProgressHUDDelegate>

@property (readwrite) BOOL needToReload;
@property (nonatomic, readwrite) MBProgressHUD *mbLoad;

@property (nonatomic, retain) NSMutableArray *mp3FileArray;

@end

@implementation WebViewController

@synthesize mbLoad;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = YES;
    
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
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:HOME_URL]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)resume
{
    //NSLog(@"resume: %d", self.needToReload);
    
    if (self.needToReload) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:HOME_URL]]];
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
        return [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:HOME_URL]]];
    }
    
    // "close" selected
    // XXX: reset
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    
    NSLog(@"shouldStartLoadWithRequest: %@", [request.URL lastPathComponent]);
    if ([[request.URL scheme] isEqual:@"passagetells"]) { // TODO && uri contains download.
        NSLog(@"passagetells scheme//download action");
        
        // Get JSON files
        // BeaconID.JSON
        [[[DataManager sharedManager] beaconIDs] removeAllObjects];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[AFNetManager sharedManager] sendGETRequestTo:BASE_URL path:@"beaconid.json" params:@{} success:^(id successBlock) {
            
            NSString *theJson= [[NSString alloc] initWithData:successBlock encoding:NSUTF8StringEncoding];
            
            NSDictionary *dict = [theJson JSONValue];
            
            for (NSString *key in [dict allKeys]) {
                NSString *value = [dict valueForKey:key];
                
                [[[DataManager sharedManager] beaconIDs] addObject:[[BeaconID alloc] initWith:[key intValue] mediaID:[value intValue]]];
            }
            
        } error:^(NSError *error) {
            NSLog(@"Please check your internet connection.");
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
        
        
        // CtrlData.JSON
        [[[DataManager sharedManager] ctrlDatas] removeAllObjects];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[AFNetManager sharedManager] sendGETRequestTo:BASE_URL path:@"ctrldata.json" params:@{} success:^(id successBlock) {
            
            NSString *theJson= [[NSString alloc] initWithData:successBlock encoding:NSUTF8StringEncoding];
            
            NSDictionary *dict = [theJson JSONValue];
            
            for (NSString *key in [dict allKeys]) {
                NSString *value = [dict valueForKey:key];
                
                [[[DataManager sharedManager] ctrlDatas] addObject:[[CtrlData alloc] initWith:key ctrlVal:value]];
            }
            
        } error:^(NSError *error) {
            NSLog(@"Please check your internet connection.");
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
        
        
        // Projects.JSON
        [[[DataManager sharedManager] projects] removeAllObjects];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[AFNetManager sharedManager] sendGETRequestTo:BASE_URL path:@"projects.json" params:@{} success:^(id successBlock) {
            
            NSString *theJson= [[NSString alloc] initWithData:successBlock encoding:NSUTF8StringEncoding];
            
            NSDictionary *dict = [theJson JSONValue];
            
            for (NSString *key in [dict allKeys]) {
                NSString *value = [dict valueForKey:key];
                
                [[[DataManager sharedManager] projects] addObject:[[Projects alloc] initWith:[key intValue] name:value]];
            }
            
        } error:^(NSError *error) {
            NSLog(@"Please check your internet connection.");
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            [self downloadMp3s];
        }];
        
        return NO;
    } else if ([[request.URL scheme] isEqual:@"jp.studiovoice.evaidios"] && [[request.URL host] isEqual:@"reader"]) {

        
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

#pragma mark -
#pragma mark Download MP3s
-(void)downloadMp3s{

    NSMutableArray *savedFiles = [[DataManager sharedManager] mp3Files];
    
    self.mp3FileArray = [[NSMutableArray alloc] init];
    
    if ([savedFiles count] == 36) {
        [self gotoNextVC];
        return;
    }
    else if ([savedFiles count] == 0) {
        self.mp3FileArray = [NSMutableArray arrayWithArray:MP3_FILES];
    }
    else
    {
        
        for (NSString *downFile in MP3_FILES) {
            
            BOOL flag = false;
            
            for (Mp3File *savedFile in savedFiles) {
                if ([downFile isEqualToString:savedFile.fileName]) {
                    flag = true;
                    break;
                }
            }
            
            if (flag) {
                continue;
            }
            else
            {
                [self.mp3FileArray addObject:downFile];
            }
        }
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
//    for (NSString *url in self.mp3FileArray) {
//        [self downloadMp3File:[NSString stringWithFormat:@"%@%@",BASE_URL,url]];
//    }
    
    [self downloadMp3File:[NSString stringWithFormat:@"%@%@",BASE_URL, self.mp3FileArray[0]]];
    
}

-(void)downloadMp3File:(NSString *)urlString {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSString *fileName = [urlString lastPathComponent];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded file to %@", path);
        
        [[[DataManager sharedManager] mp3Files] addObject:[[Mp3File alloc] initWith:fileName filePath:path]];
        
        [self.mp3FileArray removeObjectAtIndex:0];
        
        if ([self.mp3FileArray count] == 0){
            // Finish Downloading and Goto Main VC
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            [self gotoNextVC];
        }
        else
        {
            [self downloadMp3File:[NSString stringWithFormat:@"%@%@",BASE_URL, self.mp3FileArray[0]]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        if ([self.mp3FileArray count] == 0) {
            // Finish Downloading and Goto Main VC
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

            [self gotoNextVC];
        }
        else
        {
            [self downloadMp3File:[NSString stringWithFormat:@"%@%@",BASE_URL, self.mp3FileArray[0]]];
        }
    }];
    
    [operation start];
}


#pragma mark-
#pragma mark Navigation Methods
-(void)gotoNextVC{
    
    [[DataManager sharedManager] saveManager];
    
    ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
