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

@interface WebViewController () <UIWebViewDelegate, MBProgressHUDDelegate,CLLocationManagerDelegate>

@property (readwrite) BOOL needToReload;
@property (nonatomic, readwrite) MBProgressHUD *mbLoad;

@property (nonatomic, retain) NSMutableArray *mp3FileArray;

@property (readwrite) NSString *project_name;
@property (readwrite) NSString *project_id;
@property (readwrite) NSString *beaconsIDSelf;


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

    
    
    
    
    NSLog(@"shouldStartLoadWithRequest: %@", [request.URL lastPathComponent]);
    if ([[request.URL scheme] isEqual:@"passagetells"]) { // TODO && uri contains download.
        
        NSLog(@"was path was...");
        if ([actionsAndParams rangeOfString:@"download"].location != NSNotFound) {
            NSLog(@"passagetells///download action");
            
            // Get JSON files
            // BeaconID.JSON
            [[[DataManager sharedManager] beaconIDs] removeAllObjects];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            
            
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
            
            [[AFNetManager sharedManager] sendGETRequestTo:HOME_URL path:@"projects.json" params:@{} success:^(id successBlock) {
                
                NSString *theJson= [[NSString alloc] initWithData:successBlock encoding:NSUTF8StringEncoding];
                
                NSDictionary *dict = [theJson JSONValue];
                
                for (NSString *key in [dict allKeys]) {
                    NSString *value = [dict valueForKey:key];
                    
                    [[[DataManager sharedManager] projects] addObject:[[Projects alloc] initWith:[key intValue] name:value]];
                }
                
            } error:^(NSError *error) {
                NSLog(@"Please check your internet connection.");
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
            }];
            
            
            ///////////// downloading beacons
            
            NSMutableString *mutableBeaaconsURL = [NSMutableString stringWithString:HOME_URL];
            [mutableBeaaconsURL appendString:@"/"];
            
            [mutableBeaaconsURL appendString:self.project_name];
            [mutableBeaaconsURL appendString:@"/"];
            NSString *ourbeaconsurl = [NSString stringWithString:mutableBeaaconsURL];
            NSLog(ourbeaconsurl);
            [[AFNetManager sharedManager] sendGETRequestTo:ourbeaconsurl path:@"beaconid.json" params:@{} success:^(id successBlock) {
                
                NSString *theJson= [[NSString alloc] initWithData:successBlock encoding:NSUTF8StringEncoding];
                NSLog(theJson);
                [[DataManager sharedManager] setBeaconID:theJson];
                
                NSDictionary *dict = [theJson JSONValue];
                
                for (NSString *key in [dict allKeys]) {
                    NSString *value = [dict valueForKey:key];
                    
                    [[[DataManager sharedManager] beaconIDs] addObject:[[BeaconID alloc] initWith:[key intValue] mediaID:[value intValue]]];
                }
                self.beaconsIDSelf =                [[DataManager sharedManager] beaconIDs];
                NSLog(@"yearh");
                [self downloadMp3s];

            } error:^(NSError *error) {
                NSLog(@"Please check your internet connection.");
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }];
            
            
            

            
            
        }else if([actionsAndParams rangeOfString:@"selectProject"].location != NSNotFound) {
            NSLog(@"passagetells///selectProject action");
            
            //parse the url
            self.project_id = (NSString*)[queryStringDictionary objectForKey:@"id"];
            self.project_name = (NSString*)[queryStringDictionary objectForKey:@"name"];
            [[DataManager sharedManager] setProject_name:self.project_name];
            NSLog(self.project_id);
            NSLog(self.project_name);
            NSLog(@"was the project id");
            NSMutableString *projectURL = [NSMutableString stringWithString:HOME_URL];
                        [ projectURL appendString:@"/"];
            [projectURL appendString:self.project_name];
            [projectURL appendString:@"/intro.html"];
            NSLog(projectURL);
            NSString *oururl = [NSString stringWithString:projectURL];
            NSLog(oururl);
            NSURL* url = [NSURL URLWithString: oururl];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
            
            
            
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
            
            
            CLBeaconRegion *region =         [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:@"EstimoteRegion"];
            
            [self.locationManager startRangingBeaconsInRegion:region];

            
            
            
            [request setHTTPMethod:@"GET"];
            [webView loadRequest:request];
            
            
            
            
            //TODO save the project id and
            //            [[UIApplication sharedApplication] openURL:oururl];
            return NO;
        }else if([actionsAndParams rangeOfString:@"ok"].location != NSNotFound) {
     
            ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
            [self.navigationController pushViewController:vc animated:YES];

        }
        return NO;
    } else if ([[request.URL scheme] isEqual:@"mailto"] || [[request.URL scheme] isEqual:@"tel"]) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    } else {

    }
    return YES;

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
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Passagetells" message:desc delegate:self
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
        self.mp3FileArray = [NSMutableArray arrayWithArray:self.beaconsIDSelf];
    }
    else
    {
        
        for (BeaconID *beacon in self.beaconsIDSelf) {
            

            int thenumber =1*100+beacon.mediaID;
            NSString *downFile = [ NSString stringWithFormat:@"%04d%@", thenumber,@".mp3"];
            NSLog(downFile);

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
                [self.mp3FileArray addObject:beacon];
            }
        }
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //    for (NSString *url in self.mp3FileArray) {
    //        [self downloadMp3File:[NSString stringWithFormat:@"%@%@",BASE_URL,url]];
    //    }
    
    //1 hardcoded TODO

    if([self.mp3FileArray count] != 0){
        [self downloadMp3File:((BeaconID*)self.mp3FileArray[0]).mediaID];
    }else{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        [self gotoNextVC];
    }
}

- (void)downloadMp3File:(int) mediaid {
    
    int thenumber =1*100+mediaid;
    NSString *filename = [ NSString stringWithFormat:@"%04d%@", thenumber,@".mp3"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_URL, filename];

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
            NSLog(urlString);
            [self gotoNextVC];
        }
        else
        {
            [self downloadMp3File:((BeaconID*)self.mp3FileArray[0]).mediaID];

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
            [self.mp3FileArray removeObjectAtIndex:0];
            if ([self.mp3FileArray count] == 0) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                [self gotoNextVC];

            }else{
                [self downloadMp3File:((BeaconID*)self.mp3FileArray[0]).mediaID];
                
            }


        }
    }];
    
    [operation start];
}


#pragma mark-
#pragma mark Navigation Methods
-(void)gotoNextVC{
    
    [[DataManager sharedManager] saveManager];
    
    NSMutableString *projectURL = [NSMutableString stringWithString:HOME_URL];
    //            [ projectURL appendString:@"/"];
    NSLog(self.project_name);
    [projectURL appendString:@"/"];
    [projectURL appendString:self.project_name];
    [projectURL appendString:@"/"];
    [projectURL appendString:@"/instructions.html"];
    if([[DataManager sharedManager] onsite]){
//        [projectURL appendString:@"?onsite=1"];
    }
    NSLog(projectURL);
    NSString *oururl = [NSString stringWithFormat:@"%@",projectURL];
    NSLog(oururl);
    NSURL *url = [NSURL URLWithString: oururl];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];

    
    
}



/*
 Delicate method reciving beacons
 - (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
 Parameters
 manager : The location manager object reporting the event.
 beacons : An array of CLBeacon objects representing the beacons currently in range. You can use the information in these objects to determine the range of each beacon and its identifying information.
 region  : The region object containing the parameters that were used to locate the beacons
 */
#pragma mark - Location Manager
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSLog(@"mark 3");
    if([beacons count] == 0) { return; }
    if([[[DataManager sharedManager] beaconID] count]==0){
        [[DataManager sharedManager] setBeaconID:[BeaconListner parseIntoDictionary]];
    }
    CLBeacon *beacon = [ViewController getBeacon:beacons beaconID: [[DataManager sharedManager] beaconID]];
    if(beacon!=nil){
        [[DataManager sharedManager] setOnsite:TRUE];
    }
    int ii = -1, iii = 0;
    //use the first one except unknown
    for(int i = 0; i < [beacons count]; i++) {
//        var beacon = beacons[i] as! CLBeacon
//        var ttt = "\(beacon.minor):\(beacon.accuracy):\(beacon.rssi):"
//        if (beacon.proximity == CLProximity.Unknown) {
//            ttt += "Unknown\n"
//        } else if (beacon.proximity == CLProximity.Immediate) {
//            ttt += "Immediate\n"
//        } else if (beacon.proximity == CLProximity.Near) {
//            ttt += "Near\n"
//        } else if (beacon.proximity == CLProximity.Far) {
//            ttt += "Far\n"
//        }
//        if (beacon.proximity != CLProximity.Unknown && beaconID["\(beacon.major)\(beacon.minor)"] != nil && iii == 0) {
//            ii = i  // save the first one's number
//            t = ("\(ttt)\n") // save the first one's info
//            iii = 1 // the flag that the first one is got
//        }
//        tt += ttt
    }
    //D/ self.beaconlist.text = t + tt;


}


@end