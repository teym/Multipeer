//
//  Multipeer.h
//  Multipeer
//
//  Created by Mike on 3/25/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Multipeer : NSObject
@property (readonly) NSString * serviceName;
-(void) startService:(NSString *) serviceName withName:(NSString*) selfName;
@end
