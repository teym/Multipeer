//
//  MZNetService.h
//  Multipeer
//
//  Created by Mike on 14-3-29.
//  Copyright (c) 2014年 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MZPeer,MZRequest,MZResponse,MZNetDataTask;
@protocol MZNetServiceDelegate <NSObject>
-(BOOL) shouldConnect:(MZPeer*) peer type:(NSString*) type;
-(void) onRequest:(MZRequest*) request withInfo:(id) info;
-(void) onNewPeer:(MZPeer*) peer type:(NSString*) type;
@end

@interface MZNetService : NSObject
@property (weak) id<MZNetServiceDelegate> delegate;
@property (readonly) NSArray * allPeers;
-(void) startService:(NSDictionary*) info;
-(void) stopService;
-(MZNetDataTask*) request:(MZRequest*) request withFinalBlock:(void(^)(MZRequest*request,MZResponse* response,NSError*error)) block;

-(MZNetDataTask*) response:(MZResponse*) respons forRequest:(MZRequest*)request withFinalBlock:(void(^)(MZRequest*request,MZResponse* response,NSError*error))block;
@end
