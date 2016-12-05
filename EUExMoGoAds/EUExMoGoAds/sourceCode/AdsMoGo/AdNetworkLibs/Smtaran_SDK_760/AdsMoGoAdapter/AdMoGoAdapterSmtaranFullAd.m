//
//  AdMoGoAdapterSmtaranFullAd.m
//  TestMOGOSDKAPP
//
//  Created by Daxiong on 12-8-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AdMoGoAdapterSmtaranFullAd.h"
#import "AdMoGoConfigDataCenter.h"
#import "AdMoGoAdSDKInterstitialNetworkRegistry.h"

@implementation AdMoGoAdapterSmtaranFullAd

+ (AdMoGoAdNetworkType)networkType
{
    return AdMoGoAdNetworkTypeSmtaran;
}

+ (void)load
{
    [[AdMoGoAdSDKInterstitialNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd
{
    isStop = NO;
    isError = NO;
    isReady = NO;
    isPresent = NO;
    [adMoGoCore adDidStartRequestAd];
    
    NSString *publishID = [self getPublisherID:self.ration];
    NSString *slotToken = [self getSlotToken:self.ration];
    if ([publishID length] == 0 || [slotToken length] == 0) {
        NSLog(@"ERROR:mobisage<->publishID or slotToken cant be empty!");
        [adMoGoCore adapter:self didFailAd:nil];
        return;
    }
    [[MobiSageManager getInstance] setPublisherID:publishID auditFlag:nil];
    adPoster = [[MobiSagePoster alloc] initInterstitialAdSize:MobiSagePosterAdSizeNormal delegate:self slotToken:slotToken];
    [self adapterDidStartRequestAd:self];
    
    id _timeInterval = [self.ration objectForKey:@"to"];
    if ([_timeInterval isKindOfClass:[NSNumber class]]) {
        timer = [NSTimer scheduledTimerWithTimeInterval:[_timeInterval doubleValue] target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO];
    } else {
        timer = [NSTimer scheduledTimerWithTimeInterval:AdapterTimeOut15 target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO];
    }
}

- (void)stopBeingDelegate
{
    adPoster.delegate = nil;
}

- (void)stopAd
{
    isStop = YES;
    [self stopBeingDelegate];
}

- (void)stopTimer
{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)dealloc
{
    isStop = YES;
    if (adPoster) {
        adPoster.delegate = nil;
        adPoster = nil;
    }
    
    
}

- (BOOL)isReadyPresentInterstitial
{
    return isReady;
}

- (void)presentInterstitial
{
    isPresent = YES;
    [self adapter:self willPresent:nil];
    [adPoster showInterstitialAd];
    [self adapter:self didShowAd:nil];
}

- (void)loadAdTimeOut:(NSTimer*)theTimer
{
    MGLog(MGD, @"艾德思奇插屏广告超时");
    if (isStop || isError || isReady || isPresent) {
        return;
    }
    isError = YES;
    if (adPoster) {
        adPoster.delegate = nil;
    }
    [self stopTimer];
    [self adapter:self didFailAd:nil];
}

#pragma mark - MobiSagePosterAdDelegate method
- (void)mobiSagePosterAdSuccessToRequest:(MobiSagePoster *)adInterstitial
{
    if (isStop || isError || isReady ||isPresent) {
        return;
    }
    MGLog(MGD, @"艾德思奇插屏广告加载成功");
    [self stopTimer];
    isReady = YES;
    [self adapter:self didReceiveInterstitialScreenAd:adPoster];
}

- (void)mobiSagePosterAdFaildToRequest:(MobiSagePoster *)adInterstitial withError:(NSError*) error
{
    MGLog(MGD, @"艾德思奇插屏广告加载失败");
    if (isStop || isError || isReady || isPresent) {
        return;
    }
    
    isError = YES;
    if (adPoster) {
        adPoster.delegate = nil;
    }
    [self stopTimer];
    [self adapter:self didFailAd:nil];
}

- (void)mobiSagePosterAdClick:(MobiSagePoster *)adInterstitial
{
    MGLog(MGD, @"艾德思奇插屏广告被点击");
    [self specialSendRecordNum];
}

- (void)mobiSagePosterAdClose:(MobiSagePoster *)adInterstitial
{
    MGLog(MGD, @"艾德思奇插屏广告被关闭");
    [self adapter:self didDismissScreen:adInterstitial];
}

#pragma mark - Utility Method
- (NSString *)getPublisherID:(NSDictionary *)ration_dict
{
    if (ration_dict == nil || ![ration_dict isKindOfClass:[NSDictionary class]])
        return nil;
    
    NSDictionary *key = [ration_dict objectForKey:@"key"];
    if (key == nil || ![key isKindOfClass:[NSDictionary class]])
        return nil;
    
    NSString *publisherId = [key objectForKey:@"PublisherID"];
    if (publisherId == nil || ![publisherId isKindOfClass:[NSString class]])
        return nil;
    
    return publisherId;
}

- (NSString *)getSlotToken:(NSDictionary *)ration_dict
{
    if (ration_dict == nil || ![ration_dict isKindOfClass:[NSDictionary class]])
        return nil;
    
    NSDictionary *key = [ration_dict objectForKey:@"key"];
    if (key == nil || ![key isKindOfClass:[NSDictionary class]])
        return nil;
    
    NSString *slotToken = [key objectForKey:@"slotToken"];
    if (slotToken == nil || ![slotToken isKindOfClass:[NSString class]])
        return nil;
    
    return slotToken;
}

@end
