//
//  File: AdMoGoAdapterSmtaran.h
//  Project: AdsMOGO iOS SDK
//  Version: 1.1.9
//
//  Copyright 2011 AdsMogo.com. All rights reserved.
//

#import "AdMoGoAdNetworkAdapter.h"
#import "MobiSageManager.h"
#import "MobiSageBanner.h"

@interface AdMoGoAdapterSmtaran : AdMoGoAdNetworkAdapter<MobiSageBannerAdDelegate> {
	NSTimer *timer;
    MobiSageBanner *adView;
    BOOL isStop;
    BOOL isSuccess;
}

+ (AdMoGoAdNetworkType)networkType;
- (void)loadAdTimeOut:(NSTimer*)theTimer;

@end
