//
//  DataManager.h
//  passagetells
//
//  Created by HoneyPanda on 8/26/15.
//  Copyright (c) 2015 Daisuke Nakazawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

+(id)sharedManager;

@property (nonatomic, retain) NSMutableArray *beaconIDs;
@property (nonatomic, retain) NSDictionary *beaconID;
@property (nonatomic, retain) NSString *project_name;
@property (nonatomic, retain) NSMutableArray *ctrlDatas;
@property (nonatomic, retain) NSMutableArray *projects;
@property (nonatomic) BOOL onsite;

@property (nonatomic, retain) NSMutableArray *mp3Files;

-(void)saveManager;
-(void)loadManager;

@end
