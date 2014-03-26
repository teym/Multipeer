//
//  MZMultipeer.m
//  Multipeer
//
//  Created by Mike on 3/26/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "MZMultipeer.h"
#import "MZPeer_private.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

MultipeerStatus addition(MultipeerStatus s1,MultipeerStatus s2){
    return s1|s2;
}
MultipeerStatus subtraction(MultipeerStatus s1,MultipeerStatus s2){
    return ~s2&s1;
}

@interface MZMultipeer ()<MCNearbyServiceAdvertiserDelegate,MCAdvertiserAssistantDelegate,MCNearbyServiceBrowserDelegate>
@property (readwrite,assign) MultipeerStatus status;
@property (readwrite,strong) MZPeer * myself;
@property (strong) MCNearbyServiceAdvertiser * serviceAdvertiser;
@property (strong) MCNearbyServiceBrowser * serviceBrowser;
@property (strong) NSMutableDictionary * connecteds;
@property (strong) NSMutableDictionary * connectings;
@end

@implementation MZMultipeer
-(id) init{
    self = [super init];
    if(self){
        self.connecteds = [NSMutableDictionary dictionary];
        self.connectings = [NSMutableDictionary dictionary];
        self.status = MultipeerOff;
    }
    return self;
}
- (void) startService:(NSString *) serviceName withSelfName:(NSString *)selfName discoveryInfo:(NSDictionary *)dict{
    self.myself = [[MZPeer alloc] initWithName:selfName discoveryInfo:dict];
    self.myself.identify = [[MCPeerID alloc] initWithDisplayName:selfName];
    self.status = MultipeerOn;
    [self startServiceBrowser:serviceName];
    [self startServiceAdvertiser:serviceName];
}

- (void) startServiceAdvertiser:(NSString *) serviceName{
    self.serviceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.myself.identify discoveryInfo:self.myself.discoveryInfo serviceType:serviceName];
    self.serviceAdvertiser.delegate = self;
    [self.serviceAdvertiser startAdvertisingPeer];
    self.status = addition(self.status, MultipeerServiceOn);
}

- (void) startServiceBrowser:(NSString *) serviceName{
    self.serviceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.myself.identify serviceType:serviceName];
    self.serviceBrowser.delegate = self;
    [self.serviceBrowser startBrowsingForPeers];
    self.status = addition(self.status, MultipeerSearch);
}
-(void) startInvite:(MZPeer*) peer{
    
}
-(void) onNewPeer:(MCPeerID *) peerID withDiscoveryInfo:(NSDictionary *) info{
    MZPeer * peer = [self.connectings objectForKey:peerID];
    if(!peer){
        peer = [[MZPeer alloc] initWithPeerID:peerID discoveryInfo:info];
        [self.connectings setObject:peer forKey:peerID];
    }else{
        [peer updatePeerID:peerID discoveryInfo:info];
    }
    [self startInvite:peer];
}
//TODO: add timeout
-(void) onPeerLost:(MCPeerID *) peerID{
    MZPeer * peer = [self.connecteds objectForKey:peerID];
    if(peer){
        peer.status = PeerUnConnected;
        [self.connecteds removeObjectForKey:peerID];
    }
    peer = [self.connectings objectForKey:peerID];
    if(peer){
        peer.status = PeerUnConnected;
        [self.connectings removeObjectForKey:peerID];
    }
}
-(void) onReceiveInvitation:(MCPeerID*) peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler{
    MZPeer * peer = [self.connectings objectForKey:peerID];
    if(peer){
        
    }
}
#pragma mark -- ServiceAdvertiserDelegate
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler{
    
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error{
    [self.serviceAdvertiser stopAdvertisingPeer];
    self.serviceAdvertiser = nil;
    self.status = subtraction(self.status, MultipeerServiceOn);
}
#pragma mark --
- (void)advertiserAssitantWillPresentInvitation:(MCAdvertiserAssistant *)advertiserAssistant{
    
}

- (void)advertiserAssistantDidDismissInvitation:(MCAdvertiserAssistant *)advertiserAssistant{
    
}
#pragma mark -- ServiceBrowserDelegate
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info{
    [self onNewPeer:peerID withDiscoveryInfo:info];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID{
    [self onPeerLost:peerID];
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error{
    [self.serviceBrowser stopBrowsingForPeers];
    self.serviceBrowser = nil;
    self.status = subtraction(self.status, MultipeerSearch);
}
@end
