//
//  MZPeer.m
//  Multipeer
//
//  Created by Mike on 3/26/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "MZPeer.h"
#import "MZPeer_private.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@implementation MZPeer
-(id) initWithName:(NSString*) name discoveryInfo:(NSDictionary*) info{
    self = [super init];
    if(self){
        _name = name;
        _discoveryInfo = info;
        _status = PeerUnConnected;
    }
    return self;
}
-(id) initWithPeerID:(MCPeerID*) peerID discoveryInfo:(NSDictionary*) info{
    self = [super init];
    if(self){
        _name = peerID.displayName;
        _discoveryInfo = info;
        _status = PeerUnConnected;
        _identify = peerID;
    }
    return self;
}
-(void) updatePeerID:(MCPeerID*) peerID discoveryInfo:(NSDictionary*) info{
    self.identify = peerID;
    self.discoveryInfo = info;
    self.name = peerID.displayName;
}
@end
