//
//  AMPhunwareProvider.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMPhunwareProvider.h"
#import "AMNetworkConfiguration.h"
#import <PWAds.h>

@interface AMPhunwareProvider()
@property (nonatomic, assign) BOOL enabled;

@end

@implementation AMPhunwareProvider

#pragma mark - Properties

- (AMProviderType)type {
    return AMProviderTypePhunware;
}

- (AMProviderBannerType)bannerType {
    return AMProviderBannerTypeBanner;
}

- (AMProviderInterstitialType)interstitialType {
    return AMProviderInterstitialTypeInterstitial;
}

#pragma mark - Configuration

- (void)configure:(AMNetworkConfiguration *)networkConfiguration {
    self.enabled = networkConfiguration.PhunwareSiteId && [networkConfiguration.PhunwareSiteId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0 && networkConfiguration.PhunwareZoneId && [networkConfiguration.PhunwareZoneId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0;

    if (!self.enabled) {
        return;
    }
    
    [[PWAdsAppTracker sharedAppTracker] reportApplicationOpen];
}

@end
