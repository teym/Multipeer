//
//  MZPeer_private.h
//  Multipeer
//
//  Created by Mike on 3/26/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "MZPeer.h"
@class MCPeerID,MCSession;
@interface MZPeer ()
@property (readwrite,strong) NSString * name;
@property (readwrite,strong) NSDictionary * discoveryInfo;
@property (readwrite,assign) PeerStatus status;
@property (strong) MCPeerID * identify;
@property (strong) MCSession * session;
-(id) initWithName:(NSString*) name discoveryInfo:(NSDictionary*) info;
-(id) initWithPeerID:(MCPeerID*) peerID discoveryInfo:(NSDictionary*) info;
-(void) updatePeerID:(MCPeerID*) peerID discoveryInfo:(NSDictionary*) info;
@end
