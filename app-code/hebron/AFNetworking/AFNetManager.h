//
//  AFNetManager.h
//  MeoTalk
//
//  Created by HoneyPanda on 7/29/15.
//  Copyright (c) 2015 Panda. All rights reserved.
//

#import "AFHTTPClient.h"
#import <Foundation/Foundation.h>

@interface AFNetManager : NSObject

+(id) sharedManager;

-(void) sendGETRequestTo : (NSString *)url
                    path : (NSString *)path
                  params : (NSDictionary*)params
                 success : (void (^)(id))successBlock
                   error : (void (^)(NSError *error))errorBlock;

-(void) sendPOSTRequestTo : (NSString *)url
                     path : (NSString *)path
                   params : (NSDictionary*)params
                  success : (void (^)(id))successBlock
                    error : (void (^)(NSError *error))errorBlock;

-(void) downloadFile : (NSString *)urlString
             success : (void (^)(id))successBlock
               error : (void (^)(NSError *error))errorBlock;

@end
