//
//  AdMoGoAdapterDianruFullAds.m
//  TestMOGOSDKAPP
//
//  Created by mogo_wenyand on 13-12-31.
//
//

#import "AdMoGoAdapterDRFullAds.h"
#import "AdMoGoAdNetworkRegistry.h"
#import "AdMoGoAdNetworkConfig.h"
#import "AdMoGoAdNetworkAdapter+Helpers.h"
#import "AdMoGoConfigDataCenter.h"
#import "AdMoGoConfigData.h"
#import "AdMoGoDeviceInfoHelper.h"
#import "AdMoGoAdSDKInterstitialNetworkRegistry.h"

#ifndef k_dianru_btn_size
#define k_dianru_btn_size 250
#endif

@implementation AdMoGoAdapterDRFullAds


+ (AdMoGoAdNetworkType)networkType{
    return AdMoGoAdNetworkTypeDR;
}

+ (void)load{
    [[AdMoGoAdSDKInterstitialNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd{
    
    isStop = NO;
    isStopTimer = NO;
    callNum = 0;
    isPresnt = NO;
    isreceived = NO;
    isDianruDisappear = NO;
    isclicked = NO;
    [self adapterDidStartRequestAd:self];
    AdMoGoConfigDataCenter *configDataCenter = [AdMoGoConfigDataCenter singleton];
    AdMoGoConfigData *configData = [configDataCenter.config_dict objectForKey:[self getConfigKey]];
    AdViewType type = [configData.ad_type intValue];
    
    switch (type) {
        case AdViewTypeFullScreen:
        case AdViewTypeiPadFullScreen:
            break;
            
        default:
            [self adapter:self didFailAd:nil];
            return;
            break;
    }
 
    
    MGLog(MGT,@"dianru full timer %@",timer);
   
    
}

- (BOOL)isReadyPresentInterstitial{
    return YES;
}

- (void)presentInterstitial{

    
    id key = [self.ration objectForKey:@"key"];
    if ([key isKindOfClass:[NSString class]] && key != nil) {
        //DR_INIT(key, NO, nil);
        AD_INIT(key, NO, nil, AD_INSERSCREEN)
        UIViewController *uiViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        //DR_SHOW(DR_INSERSCREEN, uiViewController.view, self);
        AD_SHOW(AD_INSERSCREEN, uiViewController, self)
        
    }else{
        [self adapter:self didFailAd:nil];
        return;
    }
   

    
    id _timeInterval = [self.ration objectForKey:@"to"];
    if ([_timeInterval isKindOfClass:[NSNumber class]]) {
        timer = [NSTimer scheduledTimerWithTimeInterval:[_timeInterval doubleValue] target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO] ;
    }
    else{
        timer = [NSTimer scheduledTimerWithTimeInterval:AdapterTimeOut15 target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO] ;
    }
}

- (void)stopBeingDelegate{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)stopAd{
    
    [self stopBeingDelegate];
    isStop = YES;
}

- (void)dealloc{
    [self stopTimer];
   
}

- (void)stopTimer{
    
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

- (void)loadAdTimeOut:(NSTimer *)theTimer{
    if (isStop) {
        return;
    }
    
    [super loadAdTimeOut:theTimer];
    
    [self stopTimer];
    [self stopBeingDelegate];
    [self adapter:self didFailAd:nil];
}


#pragma mark -- DRDelegate

/**
 *  数据列表回调
 *
 *  @param object 回调的对象，如果通过AD_CREATE创建或者广告类型是banner，object就是view。否则object就是viewController
 *  @param code 广告条数大于0，那么code=0，代表成功 反之code = -1
 */
- (void)DidDataReceived:(id)object Code:(int)code
{
}

/**
 *  请求广告列表失败
 *
 *  @param object 回调的对象，如果通过AD_CREATE创建或者广告类型是banner，object就是view。否则object就是viewController
 */
- (void)DidLoadFail:(id)object
{
    //注意 有可能obj是空
    [self stopTimer];
    if(object == nil){
        // 失败
        [self adapter:self didFailAd:nil];
    }else{
        // 成功
        [self adapter:self didReceiveInterstitialScreenAd:nil];
    }
}

/**
 *  点击广告
 *
 *  @param object 广告详细信息
 */
- (void)DidViewClick:(id)object data:(id)data
{
    [self specialSendRecordNum];
}

/**
 *  关闭回调
 *
 *  @param object 回调的对象，如果通过AD_CREATE创建或者广告类型是banner，object就是view。否则object就是viewController
 */
- (void)DidViewClose:(id)object
{
    [self adapter:self didDismissScreen:nil];
}

/**
 *  广告销毁
 *
 *  @param object 回调的对象，如果通过AD_CREATE创建或者广告类型是banner，object就是view。否则object就是viewController
 */
- (void)DidViewDestroy:(id)object
{
}

///****************************************************/
///*广告列表回调                                        */
///*view :广告view                                     */
///*code :广告条数大于0，那么code=0，代表成功 反之code = -1 */
///****************************************************/
//- (void)dianruDidDataReceived:(UIView *)view
//                   dianruCode:(int)code{}
//
//
///*********************************************/
///*广告打开，如果view为空，那么表示加载广告失败      */
///*********************************************/
//- (void)dianruDidViewOpen:(UIView *)view{
//    //注意 有可能obj是空
//    [self stopTimer];
//    if(view == nil){
//        // 失败
//        [self adapter:self didFailAd:nil];
//    }else{
//        // 成功
//        [self adapter:self didReceiveInterstitialScreenAd:nil];
//    }
//}
//
///*********************/
///*点击关闭广告         */
///*不代表广告从内存中释放 */
///*********************/
//- (void)dianruDidViewClose:(UIView *)view{
//    [self adapter:self didDismissScreen:nil];
//
//}
//
///*********************/
///*从内存中销毁         */
///*********************/
//- (void)dianruDidViewDestroy:(UIView *)view{
// 
//}
//
///*********************/
///*曝光回调            */
///*********************/
//- (void)dianruDidReported:(UIView *)view
//               dianruData:(id)data{
//    [self adapter:self didShowAd:view];
//}
//
///*********************/
///*点击广告            */
///*********************/
//- (void)dianruDidClicked:(UIView *)view
//              dianruData:(id)data{
//      [self specialSendRecordNum];
//}
//
///*********************/
///*点击跳转            */
///*********************/
//- (void)dianruDidJumped:(UIView *)view
//             dianruData:(id)data{}

@end
