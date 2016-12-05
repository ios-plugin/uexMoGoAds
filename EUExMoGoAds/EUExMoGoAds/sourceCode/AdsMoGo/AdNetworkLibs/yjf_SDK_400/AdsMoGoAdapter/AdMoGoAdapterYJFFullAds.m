//
//  AdMoGoAdapterYJFFullAds.m
//  TestMOGOSDKAPP
//
//  Created by mogo_wenyand on 13-4-9.
//
//

#import "AdMoGoAdapterYJFFullAds.h"
#import "AdMoGoAdNetworkRegistry.h"
#import "AdMoGoAdNetworkConfig.h"
#import "AdMoGoAdNetworkAdapter+Helpers.h"
#import "AdMoGoConfigDataCenter.h"
#import "AdMoGoConfigData.h"
#import "AdMoGoDeviceInfoHelper.h"
#import "AdMoGoAdSDKInterstitialNetworkRegistry.h"
#import <eAd/eAd.h>
BOOL static isinit = NO;
@interface AdMoGoAdapterYJFFullAds ()<EADInterstitialAdDelegate>{
    EADInterstitialAd *interstitialAd;
}

@end

@implementation AdMoGoAdapterYJFFullAds


+ (AdMoGoAdNetworkType)networkType{
    return AdMoGoadNetworkTypeYiJiFen;
}

+ (void)load{
    [[AdMoGoAdSDKInterstitialNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd {
    
    /*
        易积分的插屏不支持ios5以下系统
     */
    if ([[UIDevice currentDevice].systemVersion intValue] < 5) {
        [self adapter:self didFailAd:nil];
        return;
    }
    isStop = NO;
    isStopTimer = NO;
    isReady = NO;
    AdMoGoConfigDataCenter *configDataCenter = [AdMoGoConfigDataCenter singleton];
    AdMoGoConfigData *configData = [configDataCenter.config_dict objectForKey:[self getConfigKey]];
    AdViewType type =[configData.ad_type intValue];
    
    switch (type) {
        case AdViewTypeFullScreen:
        case AdViewTypeiPadFullScreen:
            break;
        default:
            [self adapter:self didFailAd:nil];
            return;
            break;
    }
    
    
    
    
    id keys = [self.ration objectForKey:@"key"];
    if(keys && [keys isKindOfClass:[NSDictionary class]]){
        id APP_ID = [keys objectForKey:@"APP_ID"];
        NSString *APP_ID_Str = nil;
        if (APP_ID && [APP_ID isKindOfClass:[NSString class]]) {
            APP_ID_Str = (NSString *)APP_ID;
        }
        id APP_KEY = [keys objectForKey:@"APP_KEY"];
        NSString *APP_KEY_Str = nil;
        
        if (APP_KEY && [APP_KEY isKindOfClass:[NSString class]]) {
            APP_KEY_Str = (NSString *)APP_KEY;
        }
        id DEV_ID = [keys objectForKey:@"DEV_ID"];
        NSString *DEV_ID_Str = nil;
        if (DEV_ID && [DEV_ID isKindOfClass:[NSString class]]) {
            DEV_ID_Str = (NSString *)DEV_ID;
        }
        
        [EADConfig startWithAppId:APP_ID_Str appKey:APP_KEY_Str devId:DEV_ID_Str];
    }
    


    interstitialAd = [[EADInterstitialAd alloc] init];
    interstitialAd.delegate = self;
    [interstitialAd startLoading];

    
    id _timeInterval = [self.ration objectForKey:@"to"];
    if ([_timeInterval isKindOfClass:[NSNumber class]]) {
        timer = [NSTimer scheduledTimerWithTimeInterval:[_timeInterval doubleValue] target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO] ;
    }
    else{
        timer = [NSTimer scheduledTimerWithTimeInterval:AdapterTimeOut15 target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO] ;
    }
}

- (UIViewController *)getRootViewController
{
    UIViewController *uiViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return uiViewController;
}

- (CGRect)centerRectWithSize:(CGSize)size
{
    UIViewController *uiViewController = [self getRootViewController];
    CGRect rect = uiViewController.view.bounds;
    NSInteger height = size.height;
    NSInteger width = size.width;
    NSInteger originX = (rect.size.width - width)/2;
    NSInteger originY = (rect.size.height - height)/2;
    return CGRectMake(originX, originY, width, height);
}

- (BOOL)isReadyPresentInterstitial{
    return interstitialAd.isLoaded;
}

- (void)presentInterstitial{
     UIViewController *uiViewController = [self getRootViewController];
    if (interstitialAd.isLoaded) {
        [interstitialAd presentFromViewController:uiViewController];
        [self adapter:self willPresent:nil];
        [self adapter:self didShowAd:nil];
    }else{
        [interstitialAd startLoading];
    }
}
#pragma mark - EADInterstitialAdDelegate

/*!
 * @method splashAdDidLoad:
 *
 * @discussion
 * 广告数据获取成功
 *
 */
- (void)interstitialAdDidLoad:(EADInterstitialAd *)interstitialAd{
    isReady = YES;
    [self stopTimer];
    [self adapter:self didReceiveInterstitialScreenAd:nil];
}

/*!
 * @method splashAd:didFailWithError:
 *
 * @discussion
 * 广告数据获取失败
 *
 */
- (void)interstitialAd:(EADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error{
    [self stopTimer];
    [self adapter:self didFailAd:nil];
}

/*!
 * @method splashAdDidDisappear:
 *
 * @discussion
 * 插屏广告关闭
 *
 */
- (void)interstitialAdDidDisappear:(EADInterstitialAd *)interstitialAd{
    [self adapter:self didDismissScreen:nil];
}



-(void)stopBeingDelegate{
    if (isStop) {
        return;
    }
    [self stopTimer];
}

- (void)stopAd{
    [self stopBeingDelegate];
    isStop = YES;    
}

- (void)dealloc {
    interstitialAd.delegate = nil;

    interstitialAd = nil;
    [self stopTimer];
   
}

- (void)stopTimer {
    if (!isStopTimer) {
        isStopTimer = YES;
    }else{
        return;
    }
    if (timer) {
        [timer invalidate];
        
        timer = nil;
    }
}

- (void)loadAdTimeOut:(NSTimer*)theTimer {
    MGLog(MGD,@"易积分插屏请求超时");
    if (isStop) {
        return;
    }
    
    [super loadAdTimeOut:theTimer];
    [self stopTimer];
    [self stopBeingDelegate];
    [self adapter:self didFailAd:nil];
}

@end
