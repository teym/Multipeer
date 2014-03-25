//
//  Multipeer.m
//  Multipeer
//
//  Created by Mike on 3/25/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "Multipeer.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface Multipeer ()<MCNearbyServiceAdvertiserDelegate,MCAdvertiserAssistantDelegate,MCNearbyServiceBrowserDelegate>
@property (strong) MCPeerID * myself;
@property (strong) MCNearbyServiceAdvertiser * serviceAdvertiser;
@property (strong) MCNearbyServiceBrowser * serviceBrowser;
@property (strong) NSMutableArray * peers;
@end

@implementation Multipeer
-(id) init{
    self = [super init];
    if(self){
        self.peers = [NSMutableArray array];
    }
    return self;
}
- (void) startService:(NSString *) serviceName withName:(NSString*) selfName{
    self.myself = [[MCPeerID alloc] initWithDisplayName:selfName];
}

- (void) startServiceAdvertiser:(NSString *) serviceName{
    self.serviceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.myself discoveryInfo:@{} serviceType:serviceName];
    self.serviceAdvertiser.delegate = self;
    [self.serviceAdvertiser startAdvertisingPeer];
}

- (void) startServiceBrowser:(NSString *) serviceName{
    self.serviceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.myself serviceType:serviceName];
    self.serviceBrowser.delegate = self;
    [self.serviceBrowser startBrowsingForPeers];
}
#pragma mark -- ServiceAdvertiserDelegate
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler{
    
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error{
    
}
#pragma mark --
- (void)advertiserAssitantWillPresentInvitation:(MCAdvertiserAssistant *)advertiserAssistant{
    
}

- (void)advertiserAssistantDidDismissInvitation:(MCAdvertiserAssistant *)advertiserAssistant{
    
}
#pragma mark -- ServiceBrowserDelegate
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info{
    
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID{
    
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error{
    
}
@end
