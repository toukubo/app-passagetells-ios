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
@property (readwrite) NSMutableString *project_url;
@property (readwrite) NSString *project_firstbeacon;
@property (readwrite) NSString *beaconsIDSelf;


@property(strong, nonatomic) CLBeaconRegion *beaconRegion;
@property(strong, nonatomic) CBPeripheralManager *peripheralManager;
@property(strong, nonatomic) NSDictionary *peripheralData;

@end

@implementation WebViewController

@synthesize mbLoad;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    
    self.navigationController.navigationBarHidden = YES;
    
    // show loading indicator
    mbLoad = [[MBProgressHUD alloc] initWithView:self.view];
    mbLoad.labelText = @"Loading...";
    [self.view addSubview:mbLoad];
    [mbLoad setDelegate:self];
    [mbLoad show:YES];
//    self.webView.frame = CGRectMake(0, 50, 120, 460);

    
    self.webView.backgroundColor = [UIColor blackColor];
    self.webView.scalesPageToFit = YES;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.webView.delegate = self;
    self.webView.scrollView.bounces = NO;
    
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:HOME_URL]]];
    
    [self checkAuthorizationStatus];
}



-(void)checkAuthorizationStatus {
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
        {
            //Device does not allowed
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Service Setting" message:@"The access to location services on this app is restricted/denied. Go to Settings > Privacy > Location Services to change the setting on your phone." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: @"Cancel", nil];
            [alert setTag:1];
            [alert show];
            break;
        }
        case kCLAuthorizationStatusNotDetermined:
        {
            //Asking permission
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
                NSLog(@"requestWhenInUseAuthorization!!!");
            }
            else {
                [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
                NSLog(@"startRangingBeaconsInRegion!!!");
            }

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Service" message:@"Checking the availability of Location Service on the app." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert setTag:2];
            [alert show];
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            //Start monitoring
            NSLog(@"Location Service has been Authorized");
            NSLog(@"Monitoring");
            break;

//            for (int i=0;i<27;i++)
//            {
//                self.audio[i].volume = 0
//            }
//            //self.audio[0].volume = 1
//            [self.audio[0] playFileAsync:@"0000.mp3" target:self selector:@"PTDidStartPlay"];
//            //SoundFileLoader()
//            [self.manager startRangingBeaconsInRegion:self.region];
        }
        default:
        {
            //unknown error
            NSLog(@"unknown value in authorizationStatus");

            break;
        }
    }
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)resume{
    if (self.needToReload) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:HOME_URL]]];
    }
}

-(bool)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"clickedButtonAtIndex: %lu", (unsigned long)buttonIndex);
    
    switch([actionSheet tag]){
        case 0: { //when internet connection is refused
            if(buttonIndex == 0) {
            // "retry" selected: try to load "Top" page
            return [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:HOME_URL]]];
            }
        }
        case 1: { //Location Service Denied
            if(buttonIndex == 0) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString: UIApplicationOpenSettingsURLString]];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Service" message:@"Checking the availability of Location Service on the app." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert setTag:2];
            [alert show];
            break;
        }
        case 2: { //Location Service Not Determined
            [self checkAuthorizationStatus];
            break;
        }
        default: {
            break;
        }
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
        if([actionsAndParams rangeOfString:@"selectProject"].location != NSNotFound) {
            NSLog(@"passagetells///selectProject action");
            
            //parse the url
            self.project_id = (NSString*)[queryStringDictionary objectForKey:@"id"];
            self.project_name = (NSString*)[queryStringDictionary objectForKey:@"name"];
            
            [[DataManager sharedManager] setProject_name:self.project_name];
            
            NSLog(@"project_id / project_name: ");
            NSLog(self.project_id);
            NSLog(self.project_name);
            self.project_url = [NSMutableString stringWithString:HOME_URL];
            [self.project_url appendString:self.project_name];
            [self.project_url appendString:@"/"];
            
            [[DataManager sharedManager] setProject_url:self.project_url];
            NSLog(@"project_url: ");
            NSLog([[DataManager sharedManager] project_url]);

            NSMutableString *fileURL = [NSMutableString stringWithString:self.project_url];
            [fileURL appendString:@"intro.html"];
            NSString *oururl = [NSString stringWithString:fileURL];
            NSLog(@"Showing: ");
            NSLog(oururl);
            NSURL* url = [NSURL URLWithString: oururl];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
            
            [webView loadRequest:request];
            
            return NO;
        }else if ([actionsAndParams rangeOfString:@"download"].location != NSNotFound) {
            NSLog(@"passagetells///download action");
            
            // Get JSON files
            // BeaconID.JSON
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            
            
            // CtrlData.JSON
            [DataManager sharedManager].ctrlDatas = [[NSDictionary alloc] init];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            NSLog(@"location of ctrldata: ");
            NSLog([[DataManager sharedManager] project_url]);
            [[AFNetManager sharedManager] sendGETRequestTo:[[DataManager sharedManager] project_url] path:@"ctrldata.json" params:@{} success:^(id successBlock) {
                
                NSString *theJson= [[NSString alloc] initWithData:successBlock encoding:NSUTF8StringEncoding];
                NSLog(@"ctrldata: ");
                NSLog(theJson);
                NSDictionary *dict = [theJson JSONValue];
                
                for (NSString *key in [dict allKeys]) {
                    NSString *value = [dict valueForKey:key];
                    
                    [DataManager sharedManager].ctrlDatas = dict;
//                    [[[DataManager sharedManager] ctrlDatas] addObject:[[CtrlData alloc] initWith:key ctrlVal:value]];
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


            //firstbeacon.txt
            //[DataManager sharedManager].ctrlDatas = [[NSDictionary alloc] init];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            [[AFNetManager sharedManager] sendGETRequestTo:[[DataManager sharedManager] project_url] path:@"firstbeacon.txt" params:@{} success:^(id successBlock) {
                
                self.project_firstbeacon = [[NSString alloc] initWithData:successBlock encoding:NSUTF8StringEncoding];
                NSLog(@"firstbeacon.txt: ");
                NSLog(self.project_firstbeacon);
                [[DataManager sharedManager] setProject_firstbeacon:self.project_firstbeacon];
                
            } error:^(NSError *error) {
                NSLog(@"Please check your internet connection.");
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }];

            
            ///////////// downloading beacons
            if([[[DataManager sharedManager] beaconID] count]==0){
                
                [[DataManager sharedManager] setBeaconID:[BeaconListner parseIntoDictionary]];
            }
            
            
            
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
            
            
            CLBeaconRegion *region =         [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:@"EstimoteRegion"];
            
            [self.locationManager startRangingBeaconsInRegion:region];


            
            // mp3s
            [[[DataManager sharedManager] mp3FileNames] removeAllObjects];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            NSString *mp3sjsonurl = [NSString stringWithFormat:@"%@%@/",HOME_URL,[[DataManager sharedManager] project_name]];
            NSLog(mp3sjsonurl);
            [[AFNetManager sharedManager] sendGETRequestTo:mp3sjsonurl path:@"mp3s.json" params:@{} success:^(id successBlock) {
                
                NSString *theJson= [[NSString alloc] initWithData:successBlock encoding:NSUTF8StringEncoding];
                NSLog(@"mp3s: ");
                NSLog(theJson);
                NSArray *array = [theJson JSONValue];
//
//                for (NSString *key in [dict allKeys]) {
//                    //                    NSString *value = [dict valueForKey:key];
//                    NSLog(key);
//                    [[[DataManager sharedManager] mp3FileNames] addObject:key];
//                }
                [self downloadMp3s:array];
                
                
            } error:^(NSError *error) {
                NSLog(@"Please check your internet connection.");
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }];
            
            
            
            

        }else  if([actionsAndParams rangeOfString:@"understood"].location != NSNotFound) {
             [[DataManager sharedManager] setReadytoPlay:1];
            NSLog(@"understood: ");
            NSLog(@"%d",[DataManager sharedManager].readytoPlay);
            NSMutableString *fileURL = [NSMutableString stringWithString:[[DataManager sharedManager] project_url]];
            [fileURL appendString:@"start.html"];
            NSString *oururl = [NSString stringWithString:fileURL];
            NSLog(oururl);
            NSURL* url = [NSURL URLWithString: oururl];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
            
            [webView loadRequest:request];

            
        }else  if([actionsAndParams rangeOfString:@"play"].location != NSNotFound) {
            
            ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        return NO;
    } else if([[request.URL scheme] isEqual:@"safari"]) {
        
        NSString *filePath= [request.URL absoluteString];
        NSString *filePatha = [filePath stringByReplacingOccurrencesOfString:@"safari" withString:@"http"];
        NSLog(filePatha);
        NSURL *linkURL = [NSURL URLWithString:filePatha];
        [[UIApplication sharedApplication] openURL:linkURL];
        
        return NO;
    } else if ([[request.URL scheme] isEqual:@"mailto"] || [[request.URL scheme] isEqual:@"tel"]) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    } else if ([[request.URL scheme] isEqual:@"comgooglemaps"]) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
            [[UIApplication sharedApplication] openURL:request.URL];
        } else {
            NSLog(@"Can't use comgooglemaps://");
            NSString *filePath= [request.URL absoluteString];
            NSString *filePatha = [filePath stringByReplacingOccurrencesOfString:@"comgooglemaps://" withString:@"http://maps.apple.com/"];
            NSLog(filePatha);
            NSURL *linkURL = [NSURL URLWithString:filePatha];
            [[UIApplication sharedApplication] openURL:linkURL];

        }
        return NO;
    }else{
        
//        [[UIApplication sharedApplication] openURL:request.URL];

    }
    return YES;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSLog(@"webViewDidFinishLoad: %@", [webView.request.URL lastPathComponent]);
//    
//    NSString* js =
//    @"var meta = document.createElement('meta'); " \
//    "meta.setAttribute( 'name', 'viewport' ); " \
//    "meta.setAttribute( 'content', 'width=760px' ); " \
//    "document.getElementsByTagName('head')[0].appendChild(meta)";
//    
//    [webView stringByEvaluatingJavaScriptFromString: js];
//
//    
    if (mbLoad != nil && !mbLoad.isHidden) {
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
    
    NSString *desc = @"The app doesn't have internet connection. Please try again.";
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Passagetells" message:desc delegate:self
                                          cancelButtonTitle:@"Retry" otherButtonTitles:@"Close", nil];
    [alert setTag:0];
    [alert show];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud {
    [mbLoad removeFromSuperview];
    mbLoad = nil;
}
-(void)downloadMp3s:(NSMutableArray *)mp3FileNames{
    NSMutableArray *savedFiles = [[DataManager sharedManager] mp3Files];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(savedFiles != nil && [savedFiles count]!=0){
        Mp3File *savedFileFirst = savedFiles[0];
        if ([fileManager fileExistsAtPath:savedFileFirst.filePath]) { // yes
            NSLog(@"The files do exist");
            //[NSString stringWithFormat:@"%@ %@",@"Downloading",savedFileFirst.filePath]
            //[_sysmsg setText:@"The files do exist"];
            
        } else {
            NSLog(@"The files do not exist");
            //[_sysmsg setText:@"The files do not exist"];
            [[[DataManager sharedManager] mp3Files] removeAllObjects];
            savedFiles = [[DataManager sharedManager] mp3Files];
        }
       
    }


    self.mp3FileArray = [[NSMutableArray alloc] init];
    if ([savedFiles count] == 36) {
        [_sysmsg setText:@"count==36"];
        [self gotoNextVC];
        return;
    }    else if ([savedFiles count] == 0) {
        self.mp3FileArray = mp3FileNames;
    }    else    {
        
        for (NSString *downFile in mp3FileNames) {
//            int thenumber =1*100+beacon.mediaID;
//            NSString *downFile = [ NSString stringWithFormat:@"%04d%@", thenumber,@".mp3"];
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
            }        else        {
                [self.mp3FileArray addObject:downFile];
            }
        }
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if([self.mp3FileArray count] != 0){
        [self downloadMp3File:(NSString*)self.mp3FileArray[0]];
    }else{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [_sysmsg setText:@"MBProgressHUD"];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];
        [self gotoNextVC];
    }
}

- (void)downloadMp3File:(NSString *) filename {
    
//    int thenumber =1*100+mediaid;
//    NSString *filename = [ NSString stringWithFormat:@"%04d%@", thenumber,@".mp3"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_URL, filename];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSString *fileName = [urlString lastPathComponent];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded file to %@", path);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];

        if ([fileManager fileExistsAtPath:path]) { // yes
                NSLog(@"%@ has been downloaded", path);
                //[_sysmsg setText:[NSString stringWithFormat:@"%@ %s",path, " has been downloaded"]];
            
        } else {
                NSLog(@"%@hasn't been downloaded", path);
                //[_sysmsg setText:[NSString stringWithFormat:@"%@ %s",path, " hasn't been downloaded"]];
            
        }
        [[[DataManager sharedManager] mp3Files] addObject:[[Mp3File alloc] initWith:fileName filePath:path]];
        
        [self.mp3FileArray removeObjectAtIndex:0];
        
        if ([self.mp3FileArray count] == 0){
            // Finish Downloading and Goto Main VC
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSLog(urlString);
            //[_sysmsg setText:@"Finish DL"];
            [[DataManager sharedManager] setDownloadcompleted:TRUE];
            [self gotoNextVC];
        }        else        {
            [self downloadMp3File:(NSString*)self.mp3FileArray[0]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        if ([self.mp3FileArray count] == 0) {
            // Finish Downloading and Goto Main VC
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            //[_sysmsg setText:@"Finish DL (with errors)"];
            [self gotoNextVC];
        }     else     {
            [self.mp3FileArray removeObjectAtIndex:0];
            if ([self.mp3FileArray count] == 0) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                //[_sysmsg setText:@"Finish DL (with errors after removeObjectIndex)"];
                [self gotoNextVC];
                
            }else{
                [self downloadMp3File:(NSString*)self.mp3FileArray[0]];
            }
        }
    }];
    
    [operation start];
}


#pragma mark-
#pragma mark Navigation Methods
-(void)gotoNextVC{
    //    return ;
    [[DataManager sharedManager] saveManager];
    
    NSMutableString *fileURL = [NSMutableString stringWithString:[[DataManager sharedManager] project_url]];
    [fileURL appendString:@"slider.html"];
    if([[DataManager sharedManager] onsite]){
        [fileURL appendString:@"?onsite=1"];
    }
    NSLog(fileURL);
    NSString *oururl = [NSString stringWithFormat:@"%@",fileURL];
    NSLog(oururl);
    
    //    NSURL *url = [NSURL URLWithString: @"http://www.google.com"];
    NSURL *url = [NSURL URLWithString: oururl];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //    [self.webView stopLoading];
    
    [self.webView loadRequest:request];
    //    [self.webView stopLoading];
    
    NSLog(@"and it is done");
    
    
}


#pragma mark - Location Manager
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSLog(@"mark 3 location manager called.");
    if(beacons ==nil){
        NSLog(@"beacons are nil but didRange called");
    }else{
        NSLog(@"beacons are NOT nil and didRange called");
        
        
        if([beacons count] == 0) { return; }
        NSLog(@"beacons count is not 0");
        NSLog(@"%d",[beacons count]);
        if([[DataManager sharedManager] beaconID]==nil){
            NSLog(@"and beacon id is null");
        }
        //NSLog(@"%l",[[[DataManager sharedManager] beaconID] count]);
        
        CLBeacon *beacon = [ViewController getBeacon:beacons beaconID: [[DataManager sharedManager] beaconID]];
        if(beacon!=nil){
            
//         [[DataManager sharedManager] setOnsite:TRUE];
/*
            if([[DataManager sharedManager] onsite]){
                [_sysmsg setText:@"setOnsite: onsite=true"];
            } else {
                [_sysmsg setText:@"setOnsite: onsite=false"];
            }
*/
            if([DataManager sharedManager].onsite == false){
                [[DataManager sharedManager] setOnsite:TRUE];
                [_sysmsg setText:@"onsite status has been changed: false->true while downloading process"];
                if([DataManager sharedManager].downloadcompleted==true){
                    [self gotoNextVC];
                    [_sysmsg setText:@"onsite status has been changed: false->true while viewing slider.html"];
                }
            } else {
                NSLog(@"AAA");
                if([DataManager sharedManager].downloadcompleted==true && [DataManager sharedManager].readytoPlay > 0 ){
                    [_sysmsg setText:@"ready to play"];
                     NSString *beaconmajorminor = [NSString stringWithFormat:@"%@%@",[beacon major], [beacon minor]];
                    NSLog([DataManager sharedManager].project_firstbeacon);
                    NSLog(beaconmajorminor);
                    if([[DataManager sharedManager].project_firstbeacon isEqualToString: beaconmajorminor]){
                        if([DataManager sharedManager].downloadcompleted==true && [DataManager sharedManager].readytoPlay > 4 ){
                            [_sysmsg setText:@"Play!!!"];
                            ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
                            [self.navigationController pushViewController:vc animated:YES];
                            
                            
                            
                        } else {
                            [DataManager sharedManager].readytoPlay++;
                            NSLog(@"readytoplay value:");
                            NSLog(@"%d",[DataManager sharedManager].readytoPlay);
                        }
                    } else {
                        NSLog(@"(need more value) readytoplay value:");
                        NSLog(@"%d",[DataManager sharedManager].readytoPlay);
                    }
                } else {
                    NSLog(@"not ready to play");
                }
            }
            //NSLog(@"mark 5 beacon in the ids found. set on site. ");
            NSString *beaconmajorminor = [NSString stringWithFormat:@"%@%@",[beacon major], [beacon minor]];
            NSLog(@"beacon's major+minor: ");
            NSLog(beaconmajorminor);
        
        }
        
    }
    
    
}


@end