//
//  AFNetManager.m
//  MeoTalk
//
//  Created by HoneyPanda on 7/29/15.
//  Copyright (c) 2015 Panda. All rights reserved.
//


#import "AFNetManager.h"
#import "AFJSONRequestOperation.h"

@implementation AFNetManager

static AFNetManager *manager = nil;

+(id) sharedManager{
    if (manager == nil) {
        manager = [[AFNetManager alloc] init];
    }
    return manager;
}

-(void) sendGETRequestTo : (NSString *)url
                    path : (NSString *)path
                  params : (NSDictionary*)params
                 success : (void (^)(id))successBlock
                   error : (void (^)(NSError *error))errorBlock{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:url]];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                            path:path parameters:[params mutableCopy]];
    
    [httpClient setDefaultHeader:@"Accept" value:@"application/json"];
    
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        
        successBlock(responseObject);
        
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([[error localizedDescription] rangeOfString:@"Could not"].length>0)
        {
            NSLog(@"Erro %@",[error localizedDescription]);
        }
        if([[error localizedDescription] rangeOfString:@"appears to be offline"].length>0)
        {
            NSLog(@"Erro %@",[error localizedDescription]);
        }
        errorBlock(error);
    }];
    [operation start];
    
}

-(void) sendPOSTRequestTo : (NSString *)url
                     path : (NSString *)path
                   params : (NSDictionary*)params
                  success : (void (^)(id))successBlock
                    error : (void (^)(NSError *error))errorBlock{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:url]];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                            path:path parameters:[params mutableCopy]];
    
    [httpClient setDefaultHeader:@"Accept" value:@"application/json"];
    
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        
        successBlock(responseObject);
        
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([[error localizedDescription] rangeOfString:@"Could not"].length>0)
        {
            NSLog(@"Erro %@",[error localizedDescription]);
        }
        if([[error localizedDescription] rangeOfString:@"appears to be offline"].length>0)
        {
            NSLog(@"Erro %@",[error localizedDescription]);
        }
        errorBlock(error);
    }];
    [operation start];
}

-(void) downloadFile : (NSString *)urlString
             success : (void (^)(id))successBlock
               error : (void (^)(NSError *error))errorBlock{

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSString *fileName = [urlString lastPathComponent];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded file to %@", path);
        
        successBlock(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        errorBlock(error);
    }];
    
    [operation start];
}

@end
