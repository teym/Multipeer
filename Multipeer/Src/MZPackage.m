//
//  MZPackage.m
//  Multipeer
//
//  Created by Mike on 14-4-2.
//  Copyright (c) 2014年 Mike. All rights reserved.
//

#import "MZPackage.h"
#import "MZRequest.h"
#import "MZResponse.h"

@implementation MZPackage
+(instancetype) packageWithData:(NSData*) data{
    return [[MZRequest alloc] init];
}
+(instancetype) packageWithHeadString:(NSString *)str{
    return [[MZResponse alloc] init];
}
@end
