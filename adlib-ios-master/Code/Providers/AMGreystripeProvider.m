//
//  AMGreystripeProvider.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMGreystripeProvider.h"
#import "AMNetworkConfiguration.h"
#import "AMAdQuery.h"
#import <GSSDKInfo.h>

@interface AMGreystripeProvider()
@property (nonatomic, assign) BOOL enabled;

@end

@implementation AMGreystripeProvider

#pragma mark - Properties

- (AMProviderType)type {
    return AMProviderTypeGreystripe;
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
    self.enabled = networkConfiguration.ConversantAppId && [networkConfiguration.ConversantAppId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0;
    
    if (!self.enabled) {
        return;
    }
    
    [GSSDKInfo setGUID:networkConfiguration.ConversantAppId];
}

- (void)configureDemographics:(AMAdQuery *)demographics {
    if (demographics.location) {
        [GSSDKInfo updateLocation:demographics.location];
    }
}

@end
