//
//  DataStoreManager.m
//  RTimes
//
//  Created by Zheng on 12/4/14.
//  Copyright (c) 2014 albert. All rights reserved.
//


#import "UserDefaultsManager.h"

@interface UserDefaultsManager ()

@property (nonatomic, retain) NSUserDefaults *defaults;

@end

@implementation UserDefaultsManager
@synthesize defaults;

static UserDefaultsManager *manager = nil;

+(id)sharedManager{
    if (manager == nil) {
        manager = [[UserDefaultsManager alloc] init];
        manager.defaults = [NSUserDefaults standardUserDefaults];
    }
    return manager;
}

-(void)saveIntegerWith:(int)value
                forKey:(NSString*)key{
    [defaults setObject:[NSNumber numberWithInt:value] forKey:key];
}
-(int)loadIntegerWith:(NSString*)key{
    return [[defaults objectForKey:key] intValue];
}


-(void)saveObjectWith:(id)value
               forKey:(NSString*)key{
    [defaults setObject:value forKey:key];
    [defaults synchronize];
}
-(id)loadObjectWith:(NSString*)key{
    return [defaults objectForKey:key];
}


@end
