//
//  AMAppLovinProvider.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMAppLovinProvider.h"
#import "AMNetworkConfiguration.h"
#import <ALSdk.h>

@interface AMAppLovinProvider()
@property (nonatomic, assign) BOOL enabled;
@end

@implementation AMAppLovinProvider

#pragma mark - Properties

- (AMProviderType)type {
    return AMProviderTypeAppLovin;
}

//NOTE: AppLovin no longer supports banners....

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
    self.enabled = networkConfiguration.AppLovinSdkKey && [networkConfiguration.AppLovinSdkKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0;
    if(self.enabled) {
        [[ALSdk sharedWithKey:networkConfiguration.AppLovinSdkKey] initializeSdk];
    }
}

@end
