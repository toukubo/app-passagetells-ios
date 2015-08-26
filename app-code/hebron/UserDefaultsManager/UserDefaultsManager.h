//
//  DataStoreManager.h
//  RTimes
//
//  Created by Zheng on 12/4/14.
//  Copyright (c) 2014 albert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaultsManager : NSObject

+(id)sharedManager;

-(void)saveIntegerWith:(int)value
                forKey:(NSString*)key;
-(int)loadIntegerWith:(NSString*)key;


-(void)saveObjectWith:(id)value
               forKey:(NSString*)key;
-(id)loadObjectWith:(NSString*)key;



@end
