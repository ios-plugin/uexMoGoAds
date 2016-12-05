//
//  SmtaranNativeAdapter.h
//  test
//
//  Created by Castiel Chen on 15/1/21.
//  Copyright (c) 2015年 Castiel Chen. All rights reserved.
//

#import "AdMoGoNativeAdNetworkAdapter.h"
#import "MobiSageFactory.h"
#import "MobiSageNative.h"
#import "MobiSageManager.h"

@interface SmtaranNativeAdapter : AdMoGoNativeAdNetworkAdapter<MobiSageFactoryAdDelegate> {
    MobiSageFactory * nativeGroup;
}

@end
