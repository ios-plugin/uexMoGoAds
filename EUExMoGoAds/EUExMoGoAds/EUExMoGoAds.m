//
//  EUExMoGoAds.m
//  EUExMoGoAds
//
//  Created by wang on 16/11/29.
//  Copyright © 2016年 com.dingding.com. All rights reserved.
//

#import "EUExMoGoAds.h"
#import "AdsMOGOContent.h"

#import "AdMoGoInterstitialDelegate.h"
#import "AdMoGoInterstitialManager.h"
#import "AdMoGoLogCenter.h"

#define AdMoGoVersion @"1.7.3"


#define MoGo_ID_IPhone @"bb0bf739cd8f4bbabb74bbaa9d2768bf"
#define MoGo_ID_IPhone_ManualFresh @"b132af18e08b441185cba89b34c25061"

#define MoGo_ID_IPad @"4703de8b8e1a4951be4798fd6162577c"
#define MoGo_ID_IPad_ManualFresh @"a6a32c3cd3654d7f9b9c6f65182f1464"
#ifndef __IPHONE_3_0
#warning "This project uses features only available in iOS SDK 3.0 and later."
#endif

@interface EUExMoGoAds()
@property(nonatomic,strong)AdMoGoInterstitial *ins;
@property (nonatomic, assign) BOOL isVideo;
@property(nonatomic,assign) NSString *appkey;
@end
@implementation EUExMoGoAds//AdMob,百度,点入，多盟,广点通，InMobi,艾德思奇，易积分
@synthesize adView;
-(id)initWithWebViewEngine:(id<AppCanWebViewEngineObject>)engine{
    if (self = [ super initWithWebViewEngine:engine]) {
        
    }
    return self;
}
-(void)init:(NSMutableArray*)inArguments{
    ACArgsUnpack(NSDictionary *dic) = inArguments;
    self.appkey =dic[@"appKey"];
     [self initAd];
}
-(void)startBanner:(NSMutableArray*)inArguments{
    if (inArguments.count < 1 ) {
        return;
    }
    ACArgsUnpack(NSDictionary *dic) = inArguments;
    CGFloat x = dic[@"x"]?[dic[@"x"] floatValue]:0;
    CGFloat y = dic[@"y"]?[dic[@"y"] floatValue]:0;
    BOOL isScroll = dic[@"isScrollWithWeb"]?[dic[@"isScrollWithWeb"] boolValue]:NO;
    adView = [[AdMoGoView alloc] initWithAppKey:self.appkey
            adType:AdViewTypeNormalBanner adMoGoViewDelegate:self autoScale:YES];
    adView.adWebBrowswerDelegate = self;
    adView.frame = CGRectMake(x, y, 0.0, 0.0);
    NSLog(@"%@",NSStringFromCGRect(adView.frame));
    if (isScroll) {
         [[self.webViewEngine webScrollView]addSubview:adView];
    } else {
         [[self.webViewEngine webView]addSubview:adView];
    }
   
    
   
    
    

}
-(void)startInterstitial:(NSMutableArray*)inArguments{
  
   
    self.ins = _isVideo?[[AdMoGoInterstitialManager shareInstance] adMogoVideoInterstitialByAppKey:self.appkey]:[[AdMoGoInterstitialManager shareInstance] adMogoInterstitialByAppKey:self.appkey];
    [self.ins interstitialShow:YES];
    
}
/*
-(void)close:(NSMutableArray*)inArguments{
    if (adView) {
        [adView removeFromSuperview];
        adView.delegate = nil;
        adView = nil;
    }
    [self.ins interstitialCancel];
}
*/


- (void)initAd
{
    if (_isVideo) {
        [[AdMoGoInterstitialManager shareInstance] adMogoVideoInterstitialByAppKey:self.appkey].delegate = self;
       
    } else {
        AdMoGoInterstitial *interstitialIns = [[AdMoGoInterstitialManager shareInstance] adMogoInterstitialByAppKey:self.appkey];
        interstitialIns.delegate = self;
        
  
    }
}


#pragma mark - AdMoGoDelegate delegate

/**
 返回广告rootViewController old code
 */
- (UIViewController *)viewControllerForPresentingModalView{
    return [self.webViewEngine viewController];
}
/**
 * 广告开始请求回调
 */
- (void)adMoGoDidStartAd:(AdMoGoView *)adMoGoView
{
    ACLogDebug(@"广告开始请求回调");
}

/**
 * 广告接收成功回调
 */
- (void)adMoGoDidReceiveAd:(AdMoGoView *)adMoGoView
{
    ACLogDebug(@"广告接收成功回调");
}

/**
 * 广告接收失败回调
 */
- (void)adMoGoDidFailToReceiveAd:(AdMoGoView *)adMoGoView didFailWithError:(NSError *)error
{
    ACLogDebug(@"广告接收失败回调");
}

/**
 * 点击广告回调
 */
- (void)adMoGoClickAd:(AdMoGoView *)adMoGoView
{
    ACLogDebug(@"点击广告回调");
}

/**
 *You can get notified when the user delete the ad
 广告关闭回调
 */
- (void)adMoGoDeleteAd:(AdMoGoView *)adMoGoView
{
    ACLogDebug(@"广告关闭回调");
}

#pragma mark - AdMoGoWebBrowserControllerUserDelegate delegate

/*
 浏览器将要展示
 */
- (void)webBrowserWillAppear
{
    ACLogDebug(@"浏览器将要展示");
}

/*
 浏览器已经展示
 */
- (void)webBrowserDidAppear
{
    ACLogDebug(@"浏览器已经展示");
}

/*
 浏览器将要关闭
 */
- (void)webBrowserWillClosed
{
    ACLogDebug(@"浏览器将要关闭");
}

/*
 浏览器已经关闭
 */
- (void)webBrowserDidClosed
{
    ACLogDebug(@"浏览器已经关闭");
}

- (void)webBrowserShare:(NSString *)url{
    
}



@end
