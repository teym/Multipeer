//
//  MZNetDataTask.h
//  Multipeer
//
//  Created by Mike on 14-3-30.
//  Copyright (c) 2014年 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MZRequest,MZResponse,MZPeer;
@interface MZNetDataTask : NSObject
@property (strong) MZRequest * request;
@property (strong) MZResponse * response;
@property (assign) float * process;
@property (copy) void(^finalBlock)(MZRequest*,MZResponse*,NSError*);
@end
