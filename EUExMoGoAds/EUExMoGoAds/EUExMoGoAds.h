//
//  EUExMoGoAds.h
//  EUExMoGoAds
//
//  Created by wang on 16/11/29.
//  Copyright © 2016年 com.dingding.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppCanKit/AppCanKit.h>
#import "AdMoGoDelegateProtocol.h"
#import "AdMoGoView.h"
#import "AdMoGoWebBrowserControllerUserDelegate.h"
#import "AdMoGoInterstitial.h"
@interface EUExMoGoAds : EUExBase<AdMoGoDelegate,AdMoGoWebBrowserControllerUserDelegate,AdMoGoInterstitialDelegate>{
    AdMoGoView *adView;
}
@property (nonatomic, retain) AdMoGoView *adView;


@end
