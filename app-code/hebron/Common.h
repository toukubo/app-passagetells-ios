//
//  Common.h
//  passagetells
//
//  Created by HoneyPanda on 8/26/15.
//  Copyright (c) 2015 Daisuke Nakazawa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MBProgressHUD.h"
#import "AFNetManager.h"
#import "JSON.h"
#import "DataManager.h"
#import "AFHTTPRequestOperation.h"
#import "DataManager.h"
#import "Contants.h"


#pragma mark -

@interface BeaconID : NSObject

@property int becID;
@property int mediaID;

-(id)initWith:(int)becID
      mediaID:(int)mediaID;

@end

#pragma mark -

@interface Projects : NSObject

@property int projID;
@property (nonatomic, retain) NSString *name;

-(id)initWith:(int)projID
         name:(NSString *)name;

@end


#pragma mark -

@interface CtrlData : NSObject

@property (nonatomic, retain) NSString *ctrlID;
@property (nonatomic, retain) NSString *ctrlVal;

-(id)initWith:(NSString *)ctrlID
      ctrlVal:(NSString *)ctrlVal;

@end

#pragma mark -

@interface Mp3File : NSObject

@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *filePath;

-(id)initWith:(NSString *)fileName
     filePath:(NSString *)filePath;
-(id)initWithDict:(NSDictionary *)dict;
-(NSDictionary *)dictValue;

@end
