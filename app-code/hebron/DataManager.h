//
//  DataManager.h
//  passagetells
//
//  Created by HoneyPanda on 8/26/15.
//  Copyright (c) 2015 Daisuke Nakazawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"
@class Mp3File;

@interface DataManager : NSObject

+(DataManager *)sharedManager;

@property (nonatomic, retain) NSMutableArray *beaconIDs;
@property (nonatomic, retain) NSMutableArray *mp3FileNames;
@property (nonatomic, retain) NSDictionary *beaconID;
@property (nonatomic, retain) NSString *project_name;
@property (nonatomic, retain) NSString *project_url;
@property (nonatomic, retain) NSString *project_firstbeacon;
@property (nonatomic, retain) NSDictionary *ctrlDatas;
@property (nonatomic, retain) NSMutableArray *projects;
@property (nonatomic) BOOL onsite;
@property (nonatomic) BOOL downloadcompleted;
@property (nonatomic) int readytoPlay;

@property (nonatomic, retain) NSMutableArray *mp3Files;

-(void)saveManager;
-(void)loadManager;
+(Mp3File*)getMp3File: (NSString*)filename ;
+(NSString * __nullable)getCtrlData:(NSString*) key;


@end

