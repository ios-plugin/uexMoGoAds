//  File: AdMoGoAdapterSmtaran.m
//  Project: AdsMOGO iOS SDK
//  Version: 1.1.9
//  Copyright 2011 AdsMogo.com. All rights reserved.


#import "AdMoGoAdapterSmtaran.h"
#import "AdMoGoConfigDataCenter.h"
#import "AdMoGoAdSDKBannerNetworkRegistry.h"

@implementation AdMoGoAdapterSmtaran

+ (AdMoGoAdNetworkType)networkType
{
    return AdMoGoAdNetworkTypeSmtaran;
}

+ (void)load
{
    [[AdMoGoAdSDKBannerNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd
{
    isStop = NO;
    isSuccess = NO;
    [adMoGoCore adDidStartRequestAd];
    AdMoGoConfigDataCenter *configDataCenter = [AdMoGoConfigDataCenter singleton];
    AdMoGoConfigData *configData = [configDataCenter.config_dict objectForKey:adMoGoCore.config_key];
    
    NSString *publishID = [self getPublisherID:self.ration];
    NSString *slotToken = [self getSlotToken:self.ration];
    if ([publishID length] == 0 || [slotToken length] == 0) {
        NSLog(@"ERROR:mobisage<->publishID or slotToken cant be empty!");
        [adMoGoCore adapter:self didFailAd:nil];
        return;
    }
    [[MobiSageManager getInstance] setPublisherID:publishID];
    
    AdViewType type =[configData.ad_type intValue];
    switch (type) {
        case AdViewTypeNormalBanner:
        case AdViewTypeiPadNormalBanner:
            adView = [[MobiSageBanner alloc] initBannerAdSize:MobiSageBannerAdSizeNormal delegate:self slotToken:slotToken];
            [adView setBannerAdAnimeType:MobiSageBannerAdAnimationTypeNone];
            [adView setBannerAdRefreshTime:MobiSageBannerAdRefreshTimeNone];
            break;
        case AdViewTypeLargeBanner:
            adView = [[MobiSageBanner alloc]initBannerAdSize:MobiSageBannerAdSizeLarge delegate:self slotToken:slotToken];
            [adView setBannerAdAnimeType:MobiSageBannerAdAnimationTypeNone];
            [adView setBannerAdRefreshTime:MobiSageBannerAdRefreshTimeNone];
            break;
        default:
            MGLog(MGD, @"smtaran 对这种广告形式不支持");
            [adMoGoCore adapter:self didFailAd:nil];
            return;
    }
    
    id _timeInterval = [self.ration objectForKey:@"to"];
    if ([_timeInterval isKindOfClass:[NSNumber class]]) {
        timer = [NSTimer scheduledTimerWithTimeInterval:[_timeInterval doubleValue] target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO];
    } else {
        timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO] ;
    }
    self.adNetworkView = adView;
    
}

- (void)stopBeingDelegate
{
    adView.delegate = nil;
}

- (void)stopAd
{
    [self stopBeingDelegate];
    isStop = YES;
    [self stopTimer];
}

- (void)stopTimer
{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)loadAdTimeOut:(NSTimer*)theTimer
{
    if (isStop) {
        return;
    }
    
    [self stopTimer];
    
    [adMoGoCore adapter:self didFailAd:nil];
}

- (void)dealloc
{
    isStop = YES;
    adView.delegate = nil;
}

- (BOOL)isSDKSupportClickDelegate
{
    return YES;
}

#pragma mark - SmtaranBannerAdDelegate method
- (void)mobiSageBannerAdSuccessToShowAd:(MobiSageBanner *)adBanner
{
    MGLog(MGD, @"艾德思奇横幅广告展示成功");
    if (isSuccess) {
        return;
    }
    isSuccess = YES;
    if (isStop) {
        return;
    }
    [self stopTimer];
    
    [adMoGoCore adapter:self didReceiveAdView:self.adNetworkView];
}

- (void)mobiSageBannerAdFaildToShowAd:(MobiSageBanner *)adBanner withError:(NSError*) error
{
    MGLog(MGE, @"艾德思奇横幅广告展示失败 %@",error);
    if (isStop) {
        return;
    }
    [self stopTimer];
    [adMoGoCore adapter:self didFailAd:error];
}

- (void)mobiSageBannerAdClick:(MobiSageBanner *)adBanner
{
    MGLog(MGD, @"艾德思奇横幅广告被点击");
    [adMoGoCore sdkplatformSendCLK:self];
}

- (void)mobiSageBannerLandingPageShowed:(MobiSageBanner *)adBanner
{
    MGLog(MGD, @"艾德思奇横幅广告打开LandingSite");
    if (isStop) {
        return;
    }
    [adMoGoCore stopTimer];
    if ([adMoGoDelegate respondsToSelector:@selector(adMoGoWillPresentFullScreenModal)]) {
        [adMoGoDelegate adMoGoWillPresentFullScreenModal];
    }
}

- (void)mobiSageBannerLandingPageHided:(MobiSageBanner *)adBanner
{
    MGLog(MGD, @"艾德思奇横幅广告关闭LandingSite");
    if (isStop) {
        return;
    }
    [adMoGoCore stopTimer];
    if ([adMoGoDelegate respondsToSelector:@selector(adMoGoDidDismissFullScreenModal)]) {
        [adMoGoDelegate adMoGoDidDismissFullScreenModal];
    }
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
