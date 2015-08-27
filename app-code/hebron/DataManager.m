//
//  DataManager.m
//  passagetells
//
//  Created by HoneyPanda on 8/26/15.
//  Copyright (c) 2015 Daisuke Nakazawa. All rights reserved.
//

#import "Common.h"
#import "DataManager.h"

#import "UserDefaultsManager.h"

@implementation DataManager

static DataManager *manager = nil;

+(id)sharedManager{
    if (manager == nil) {
        manager = [[DataManager alloc] init];
        
        [manager initManager];
    }
    return manager;
}

-(void)initManager{
    self.beaconIDs = [[NSMutableArray alloc] init];
    self.beaconID = [[NSString alloc] init];
    self.project_name = [[NSString alloc] init];
    self.ctrlDatas = [[NSMutableArray alloc] init];
    self.projects = [[NSMutableArray alloc] init];
    
    self.mp3Files = [[NSMutableArray alloc] init];
    
    [self loadManager];
}

-(void)saveManager{
    
    // saving mp3files
    NSMutableArray *saveArray = [[NSMutableArray alloc] init];
    for (Mp3File *file in self.mp3Files) {
        [saveArray addObject:[file dictValue]];
    }
    
    [[UserDefaultsManager sharedManager] saveObjectWith:saveArray forKey:@"mp3Files"];
}
-(void)loadManager{
    NSArray *loadArray = [[UserDefaultsManager sharedManager] loadObjectWith:@"mp3Files"];
    for (NSDictionary *dict in loadArray) {
        [self.mp3Files addObject:[[Mp3File alloc] initWithDict:dict]];
    }
}

@end
