//
//  MZPeer.h
//  Multipeer
//
//  Created by Mike on 3/26/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{PeerUnConnected,PeerConnecting,PeerConnected} PeerStatus;

@interface MZPeer : NSObject
@property (readonly) NSString * name;
@property (readonly) NSDictionary * discoveryInfo;
@property (readonly) PeerStatus status;
@end
