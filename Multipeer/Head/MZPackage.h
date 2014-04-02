//
//  MZPackage.h
//  Multipeer
//
//  Created by Mike on 14-4-2.
//  Copyright (c) 2014年 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface MZPackage : NSObject
+(instancetype) packageWithData:(NSData*) data;
+(instancetype) packageWithHeadString:(NSString *)str;
@property (strong) NSString * resource;
@property (strong) NSString * method;
@property (strong) NSString* MIMEType;
@property (strong) NSDictionary * info;
@property (strong) NSURL * localFile;
@property (strong) id data;
@property (strong) NSError * error;
@property (strong) NSProgress * progress;
@end
