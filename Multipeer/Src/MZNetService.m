//
//  MZNetService.m
//  Multipeer
//
//  Created by Mike on 14-3-29.
//  Copyright (c) 2014年 Mike. All rights reserved.
//

#import "MZNetService.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "MZRequest.h"
#import "MZResponse.h"
#import "MZNetDataTask.h"
#import "MZPeer.h"

#define ServiceType @"MZ-pub"

@interface MZNetService ()<MCSessionDelegate,MCNearbyServiceAdvertiserDelegate,MCNearbyServiceBrowserDelegate>
@property (strong) dispatch_queue_t sendQueue;
@property (strong) dispatch_queue_t processQueue;
@property (strong) NSMutableDictionary * requested;
@property (strong) NSMutableDictionary * recving;
@property (strong) NSMutableDictionary * connectedPeers;
@property (strong) MZPeer * peer;
@property (strong) MCSession * session;
@property (strong) MCNearbyServiceAdvertiser * advertiser;
@property (strong) MCNearbyServiceBrowser * browser;
@end

@implementation MZNetService
-(id) init{
    self = [super init];
    if(self){
        _allPeers = [NSMutableArray array];
        self.sendQueue = dispatch_queue_create("mz-send", DISPATCH_QUEUE_SERIAL);
        self.processQueue = dispatch_queue_create("mz-process", DISPATCH_QUEUE_SERIAL);
        self.requested = [NSMutableDictionary dictionary];
        self.recving = [NSMutableDictionary dictionary];
        self.connectedPeers = [NSMutableDictionary dictionary];
    }
    return self;
}
-(NSString*) getSelfIden{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}
-(void) startService:(NSDictionary *)info{
    self.peer = [[MZPeer alloc] initWithPeer:[[MCPeerID alloc] initWithDisplayName:[self getSelfIden]] info:info];
    self.session = [[MCSession alloc] initWithPeer:self.peer.peer];
    self.session.delegate = self;
    
    self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peer.peer discoveryInfo:info serviceType:ServiceType];
    self.advertiser.delegate = self;
    
    self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peer.peer serviceType:ServiceType];
    self.browser.delegate = self;
    
    [self.browser startBrowsingForPeers];
    [self.advertiser startAdvertisingPeer];
}
-(void) stopService{
    self.advertiser.delegate = nil;
    [self.advertiser stopAdvertisingPeer];
    self.browser.delegate = nil;
    [self.browser startBrowsingForPeers];
    self.session.delegate = nil;
    [self.session disconnect];
    //clean request recving peers
}

-(MZNetDataTask*) request:(MZRequest*) request withFinalBlock:(void(^)(MZRequest*request,MZResponse* response,NSError*error)) block{
    MZNetDataTask * task = [[MZNetDataTask alloc] init];
    task.request = request;
    task.finalBlock = block;
    [self startTask:task];
    return task;
}

-(MZNetDataTask*) response:(MZResponse*) respons forRequest:(MZRequest*)request withFinalBlock:(void(^)(MZRequest*request,MZResponse* response,NSError*error))block{
    MZNetDataTask * task = [[MZNetDataTask alloc] init];
    task.request = request;
    task.response = respons;
    task.finalBlock = block;
    [self startTask:task];
    return task;
}
-(void) startTask:(MZNetDataTask*) task{
    
}
-(void) onPeer:(MCPeerID*)peerID changeState:(MCSessionState) state{
    MZPeer * peer = [self.connectedPeers objectForKey:peerID.displayName];
    switch (state) {
        case MCSessionStateConnecting:
            peer.status = PeerConnecting;
            break;
        case MCSessionStateConnected:
            peer.status = PeerConnected;
            break;
        case MCSessionStateNotConnected:
            peer.status = PeerUnConnected;
            [self.connectedPeers removeObjectForKey:peerID.displayName];
        default:
            break;
    }
}
-(void) onPeerLost:(MCPeerID*)peerID{
    MZPeer * peer = [self.connectedPeers objectForKey:peerID.displayName];
    peer.status = PeerUnConnected;
    [self.connectedPeers removeObjectForKey:peer.name];
}
-(void) onNewPeer:(MCPeerID*)peerID info:(id) info type:(NSString*)type{
    MZPeer * peer = [self.connectedPeers objectForKey:peerID.displayName];
    if(!peer){
        peer = [[MZPeer alloc] initWithPeer:peerID info:info];
    }else{
        peer.discoveryInfo = info;
    }
    peer.status = PeerConnecting;
    [self.connectedPeers setObject:peer forKey:peer.name];
    
    [self.delegate onNewPeer:peer type:type];
}
-(void) onPackBeginSend:(MZPackage*) pack withPeer:(MCPeerID*) peerID{
    
}
-(void) onPackEndSend:(MZPackage*) pack withPeer:(MCPeerID*) peerID{
    
}
-(void) onPackBeginRecv:(MZPackage*) pack withPeer:(MCPeerID*) peerID{
    
}
-(void) onPackEndRecv:(MZPackage*) pack withPeer:(MCPeerID*) peerID{
    
}
#pragma mark - MCSessionDelegate protocol conformance

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    dispatch_async(self.processQueue, ^{
        [self onPeer:peerID changeState:state];
    });
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    dispatch_async(self.processQueue, ^{
        MZPackage * pack = [MZPackage packageWithData:data];
        [self onPackBeginRecv:pack withPeer:peerID];
        [self onPackEndRecv:pack withPeer:peerID];
    });
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    dispatch_async(self.processQueue, ^{
        MZPackage * pack = [MZPackage packageWithHeadString:resourceName];
        pack.progress = progress;
        [self onPackBeginRecv:pack withPeer:peerID];
    });
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    dispatch_async(self.processQueue, ^{
        NSString * packKey = [self keyForPack:resourceName];
        MZPackage* pack = [self.recving objectForKey:packKey];
        if(error){
            pack.error = error;
        }
        else{
            pack.localFile = localURL;
        }
        [self onPackEndRecv:pack withPeer:peerID];
    });
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    //    NSLog(@"didReceiveStream %@ from %@", streamName, peerID.displayName);
}

#pragma mark - protocal
-(NSString *) keyForPack:(NSString*) str{
    return @"";
}
-(id) objForPack:(NSString*) str{
    return nil;
}

#pragma mark - MCNearbyServiceBrowserDelegate protocol conformance

- (void) checkPeer:(MCPeerID*) peer info:(id)info type:(NSString*)type withBlock:(void(^)(BOOL))block{
    MZPeer * newPeer = [[MZPeer alloc] initWithPeer:peer info:info];
    BOOL ret = [self.delegate shouldConnect:newPeer type:type];
    block(ret);
}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    dispatch_async(self.processQueue, ^{
        [self checkPeer:peerID info:info type:@"inviter" withBlock:^(BOOL invite) {
            if(invite){
                NSData * data = nil;
                if(self.peer.discoveryInfo){
                    data = [NSJSONSerialization dataWithJSONObject:self.peer.discoveryInfo options:NSJSONWritingPrettyPrinted error:nil];
                }
                [browser invitePeer:peerID toSession:self.session withContext:data timeout:30.0];
                [self onNewPeer:peerID info:info type:@"inviter"];
            }
        }];
    });
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    dispatch_async(self.processQueue, ^{
        [self onPeerLost:peerID];
    });
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"didNotStartBrowsingForPeers: %@", error);
}

#pragma mark - MCNearbyServiceAdvertiserDelegate protocol conformance

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
{
    dispatch_async(self.processQueue, ^{
        id info = nil;
        if(context){
            info = [NSJSONSerialization JSONObjectWithData:context options:NSJSONReadingMutableLeaves error:nil];
        }
        [self checkPeer:peerID info:info type:@"advertiser" withBlock:^(BOOL recv) {
            invitationHandler(recv, self.session);
            [self onNewPeer:peerID info:info type:@"advertiser"];
        }];
    });
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"didNotStartAdvertisingForPeers: %@", error);
}
@end
