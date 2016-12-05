//
//  SmtaranNativeAdapter.m
//  test
//
//  Created by Castiel Chen on 15/1/21.
//  Copyright (c) 2015年 Castiel Chen. All rights reserved.
//

#import "SmtaranNativeAdapter.h"
#import "AdsMogoNativeAdInfo.h"

@interface SmtaranNativeAdapter (){
    int requestCount;
    NSMutableArray * adArray;
    BOOL isTimerOut;
    AdsMogoNativeAdInfo* clickInfo;
}

@end


@implementation SmtaranNativeAdapter
+ (AdMoGoNativeAdNetworkType)networkType
{
    return AdMoGoNativeAdNetworkTypeSmtaran;
}

+ (void)load
{
    [[AdMoGoNativeRegistry sharedRegistry] registerClass:self];
}

- (void)loadAd:(int)adcount
{
    isTimerOut = NO;
    adArray = [[NSMutableArray alloc] init];
    
    NSString *publishID = [self getPublisherID:self.ration];
    NSString *slotToken = [self getSlotToken:self.ration];
    if ([publishID length] == 0 || [slotToken length] == 0) {
        NSLog(@"ERROR:mobisage<->publishID or slotToken cant be empty!");
        [self adMogoNativeFailAd:-1];
        return;
    }
    [[MobiSageManager getInstance] setPublisherID:publishID auditFlag:nil];
    
    nativeGroup = [[MobiSageFactory alloc] init];
    nativeGroup.delegate = self;
    nativeGroup.capacity = adcount;//请求广告数量
    requestCount = adcount;
    
    [nativeGroup requestWithWidth:320.0f slotToken:slotToken completion:nil];
}

//展示广告
- (void)attachAdView:(UIView *)view nativeData:(AdsMogoNativeAdInfo *)info
{
    [super attachAdView:view nativeData:info];
    [view addSubview:[info valueForKey:AdsMoGoNativeMoGoPdata]];
    [view bringSubviewToFront:[info valueForKey:AdsMoGoNativeMoGoPdata]];
}

//点击广告
- (void)clickAd:(AdsMogoNativeAdInfo *)info
{
    [super clickAd:info];
}

//请求广告超时
- (void)loadAdTimeOut:(NSTimer*)theTimer
{
    isTimerOut =YES;
    [super loadAdTimeOut:theTimer];
    if (adArray && adArray.count > 1) {
        [self adMogoNativeSuccessAd:adArray];
    } else {
        [self adMogoNativeFailAd:-1];
    }
}

/**
 *  adFactory请求成功
 *  @param adNative
 */
- (void)mobiSageFactoryAdSuccessToRequest:(MobiSageFactory*) adFactory
{
    NSArray *array = adFactory.adViews;
    for (id smtarannative in array) {
        if ([smtarannative isKindOfClass:[MobiSageNative class]]) {
            MobiSageNative * adNative = (MobiSageNative *)smtarannative;
            AdsMogoNativeAdInfo *adsMogoNativeInfo =[[AdsMogoNativeAdInfo alloc] init];
            [adsMogoNativeInfo setValue:[adNative.content objectForKey:@"title"] forKey:AdsMoGoNativeMoGoTitle];
            [adsMogoNativeInfo setValue:[adNative.content objectForKey:@"logo"] forKey:AdsMoGoNativeMoGoIconUrl];
            [adsMogoNativeInfo setValue:[adNative.content objectForKey:@"desc"] forKey:AdsMoGoNativeMoGoDesc];
            [adsMogoNativeInfo setValue:[adNative.content objectForKey:@"image"] forKey:AdsMoGoNativeMoGoImageUrl];
            [adsMogoNativeInfo setValue:adNative forKey:AdsMoGoNativeMoGoPdata];
            [adsMogoNativeInfo setValue:[self getMogoJsonByDic:adsMogoNativeInfo] forKey:AdsMoGoNativeMoGoJsonStr];
            [adArray addObject:adsMogoNativeInfo];
            [self adMogoNativeSuccessAd:adArray];
        }
    }
}

/**
 *  adFactory请求失败
 *  @param adFactory
 */
- (void)mobiSageFactoryAdFaildToRequest:(MobiSageFactory*)adFactory withError:(NSError*) error
{
    [self adMogoNativeFailAd:-1];
}

#pragma mark - SmtaranNativeDelegate
- (void)mobiSageNativeAdClick:(MobiSageNative*)adNative
{
    if (clickInfo) {
        clickInfo =nil;
    }
    clickInfo =[[AdsMogoNativeAdInfo alloc]init];
    [clickInfo setValue:[adNative.content objectForKey:@"title"] forKey:AdsMoGoNativeMoGoTitle];
    [clickInfo setValue:[adNative.content objectForKey:@"logo"] forKey:AdsMoGoNativeMoGoIconUrl];
    [clickInfo setValue:[adNative.content objectForKey:@"desc"] forKey:AdsMoGoNativeMoGoDesc];
    [clickInfo setValue:[adNative.content objectForKey:@"image"] forKey:AdsMoGoNativeMoGoImageUrl];
    [clickInfo setValue:adNative forKey:AdsMoGoNativeMoGoPdata];
    [clickInfo setValue:[self getMogoJsonByDic:clickInfo] forKey:AdsMoGoNativeMoGoJsonStr];
    [self clickAd:clickInfo];
}

- (void)mobiSageNativeAdAppeared:(MobiSageNative*) adNative
{
    NSLog(@" --------smtaranNativeAppeared:(%@)",adNative.content[@"id"]);
}

- (void)dealloc
{
    if (nativeGroup) {
        nativeGroup=nil;
    }
    
    if(clickInfo){
        clickInfo=nil;
    }
   }

#pragma mark - Utility Method
- (NSString *)getPublisherID:(NSDictionary *)ration_dict
{
    if (ration_dict == nil || ![ration_dict isKindOfClass:[NSDictionary class]])
        return nil;
    
    NSDictionary *key = [ration_dict objectForKey:@"k"];
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
    
    NSDictionary *key = [ration_dict objectForKey:@"k"];
    if (key == nil || ![key isKindOfClass:[NSDictionary class]])
        return nil;
    
    NSString *slotToken = [key objectForKey:@"slotToken"];
    if (slotToken == nil || ![slotToken isKindOfClass:[NSString class]])
        return nil;
    
    return slotToken;
}

@end
