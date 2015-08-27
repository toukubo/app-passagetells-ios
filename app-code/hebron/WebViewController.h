//
//  WebViewController.h
//  passagetells
//
//  Created by HoneyPanda on 8/26/15.
//  Copyright (c) 2015 Daisuke Nakazawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@interface WebViewController : UIViewController  <UIWebViewDelegate, MBProgressHUDDelegate,CLLocationManagerDelegate,CBPeripheralDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (readwrite) CLLocationManager *locationManager;

@end
