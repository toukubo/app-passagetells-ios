//
//  Common.m
//  passagetells
//
//  Created by HoneyPanda on 8/26/15.
//  Copyright (c) 2015 Daisuke Nakazawa. All rights reserved.
//

#import "Common.h"

#pragma mark -

@implementation BeaconID

-(id)initWith:(int)becID
      mediaID:(int)mediaID
{
    if (self = [super init]) {
        
        self.becID = becID;
        self.mediaID = mediaID;
        
    }
    return self;
}

@end


@implementation Projects

-(id)initWith:(int)projID
         name:(NSString *)name
{
    if (self = [super init]) {
        
        self.projID = projID;
        self.name = name;
        
    }
    return self;
}

@end

@implementation CtrlData

-(id)initWith:(NSString *)ctrlID
      ctrlVal:(NSString *)ctrlVal
{
    if (self = [super init]) {
        
        self.ctrlID = ctrlID;
        self.ctrlVal = ctrlVal;
        
    }
    return self;
}

@end


@implementation Mp3File

-(id)initWith:(NSString *)fileName
     filePath:(NSString *)filePath
{
    if (self = [super init]) {
        
        self.fileName = fileName;
        self.filePath = filePath;
        
    }
    return self;
}

-(id)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        
        self.fileName = [dict valueForKey:@"fileName"];
        self.filePath = [dict valueForKey:@"filePath"];
        
    }
    return self;
}

-(NSDictionary *)dictValue{
    return @{@"fileName":self.fileName, @"filePath":self.filePath};
}

@end