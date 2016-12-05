//
//  AdMoGoAdapterSmtaranFullAd.h
//  TestMOGOSDKAPP
//
//  Created by Daxiong on 12-8-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AdMoGoAdNetworkInterstitialAdapter.h"
#import "MobiSageManager.h"
#import "MobiSagePoster.h"

@interface AdMoGoAdapterSmtaranFullAd : AdMoGoAdNetworkInterstitialAdapter<MobiSagePosterAdDelegate>
{
    NSTimer *timer;
    BOOL isStop;
    BOOL isError;
    BOOL isReady;
    BOOL isPresent;
    MobiSagePoster *adPoster;
}

+ (AdMoGoAdNetworkType)networkType;
- (void)loadAdTimeOut:(NSTimer*)theTimer;

@end
