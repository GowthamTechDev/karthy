//
//  AMAdMobProvider.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMAdMobProvider.h"
#import "AMNetworkConfiguration.h"

@interface AMAdMobProvider()
@property (nonatomic, assign) BOOL enabled;

@end

@implementation AMAdMobProvider

#pragma mark - Properties

- (AMProviderType)type {
    return AMProviderTypeAdMob;
}

- (AMProviderBannerType)bannerType {
    return AMProviderBannerTypeBanner;
}

- (AMProviderInterstitialType)interstitialType {
    return AMProviderInterstitialTypeInterstitial;
}

- (BOOL)enabled {
    return _enabled;
}

#pragma mark - Configuration

- (void)configure:(AMNetworkConfiguration *)networkConfiguration {
    self.enabled = networkConfiguration.AdMobAdUnitId && [networkConfiguration.AdMobAdUnitId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0;
}

@end
