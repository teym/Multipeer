//
//  MZMultipeer.h
//  Multipeer
//
//  Created by Mike on 3/26/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MZPeer.h"

typedef enum{
    MultipeerOff = 0,
    MultipeerOn = 1>>1,
    MultipeerSearch = 1>>2,
    MultipeerServiceOn = 1>>3
    } MultipeerStatus;
@interface MZMultipeer : NSObject
@property (readonly) MZPeer * myself;
@property (readonly) NSString * serviceName;
@property (readonly) MultipeerStatus status;
-(void) startService:(NSString *) serviceName withSelfName:(NSString*) selfName discoveryInfo:(NSDictionary*) dict;
@end
