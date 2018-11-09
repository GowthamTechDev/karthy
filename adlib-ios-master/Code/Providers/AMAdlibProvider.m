//
//  AMAdlibProvider.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMAdlibProvider.h"

@implementation AMAdlibProvider

#pragma mark - Properties

- (AMProviderType)type {
    return AMProviderTypeAdlib;
}

- (AMProviderBannerType)bannerType {
    return AMProviderBannerTypeBanner;
}


- (AMProviderInterstitialType)interstitialType {
    return AMProviderInterstitialTypeInterstitial;
}

- (BOOL)enabled {
    return YES;
}

@end
