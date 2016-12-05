//
//  AdMoGoAdapterDianruFullAds.h
//  TestMOGOSDKAPP
//
//  Created by mogo_wenyand on 13-12-31.
//
//

#import "AdMoGoAdNetworkInterstitialAdapter.h"
#import "AdMoGoAdNetworkAdapter.h"

//#import "PutNoise.h"
#import "ZSDK.h"

@interface AdMoGoAdapterDRFullAds : AdMoGoAdNetworkInterstitialAdapter<ZDelegate>{
    
    NSTimer *timer;
    BOOL isStop;
    BOOL isStopTimer;
    int callNum;
    BOOL isPresnt;
    BOOL isreceived;
    BOOL isDianruDisappear;
    BOOL isclicked;
}
+ (AdMoGoAdNetworkType)networkType;
- (void)getAd;
- (void)stopBeingDelegate;
- (void)stopTimer;
- (void)stopAd;
- (void)dealloc;
@end
