//
//  AMPhunwareAdapter.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMPhunwareBannerAdapter.h"
#import "AMNetworkConfiguration.h"
#import "AdlibClient.h"
#import "AMClientConfiguration.h"
#import "AMDemographics.h"
#import <PWAds.h>

@interface AMPhunwareBannerAdapter() <PWAdsBannerAdViewDelegate>
@property (nonatomic, strong) PWAdsBannerAdView *tapItBannerView;
@property (nonatomic, strong) PWAdsRequest *tapItRequest;
@end

@implementation AMPhunwareBannerAdapter
@synthesize provider = _provider;
@synthesize completion = _completion;
@synthesize tapped = _tapped;
@synthesize forceAPINext = _forceAPINext;

#pragma mark - Properties

- (PWAdsBannerAdView *)tapItBannerView {
    if (_tapItBannerView) {
        return _tapItBannerView;
    }
    
    _tapItBannerView = [[PWAdsBannerAdView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 50.0f)];
    
    return _tapItBannerView;
}

- (UIView *)bannerView {
    return self.tapItBannerView;
}

#pragma mark - ALAdNetworkBannerAdapter

- (void)configure:(AMNetworkConfiguration *)networkConfiguration bannerView:(AMBannerView *)bannerView {
    if (networkConfiguration.PhunwareZoneId) {
        self.tapItRequest = [PWAdsRequest requestWithAdZone:networkConfiguration.PhunwareZoneId];
    }
    self.tapItBannerView.delegate = self;
}

- (void)loadBanner {
    AMDemographics *query = [AdlibClient sharedClient].demographics;
    if (query && query.location) {
        [self.tapItRequest updateLocation:query.location];
    }

    [self.tapItBannerView startServingAdsForRequest:self.tapItRequest];
}

#pragma mark - TapItBannerAdViewDelegate

- (void)pwBannerAdViewDidLoadAd:(PWAdsBannerAdView *)bannerView {
    if (self.completion) self.completion(YES, self, self.provider.name);
    
    // Stop TapIt from refreshing ads.
    [self.tapItBannerView cancelAds];
}

- (void)pwBannerAdView:(PWAdsBannerAdView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    if (self.completion) self.completion(NO, self, self.provider.name);
    
    // Stop TapIt from refreshing ads.
    [self.tapItBannerView cancelAds];
}

- (BOOL)pwBannerAdViewActionShouldBegin:(PWAdsBannerAdView *)bannerView willLeaveApplication:(BOOL)willLeave {
    if (self.tapped) self.tapped(self, self.provider.name);
    return YES;
}

@end
