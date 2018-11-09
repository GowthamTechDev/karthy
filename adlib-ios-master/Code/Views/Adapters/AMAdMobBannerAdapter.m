//
//  ALAdMobBannerViewAdapter.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMAdMobBannerAdapter.h"
#import "AMNetworkConfiguration.h"
#import "AdlibClient.h"
#import "AMDemographics.h"
#import <CoreLocation/CoreLocation.h>

@import GoogleMobileAds;

@interface AMAdMobBannerAdapter() <GADBannerViewDelegate>
@property (nonatomic, strong) GADBannerView *adMobBannerView;

@end

@implementation AMAdMobBannerAdapter
@synthesize provider = _provider;
@synthesize completion = _completion;
@synthesize tapped = _tapped;
@synthesize forceAPINext = _forceAPINext;

#pragma mark - Properties

- (GADBannerView *)adMobBannerView {
    if (_adMobBannerView) {
        return _adMobBannerView;
    }
    _adMobBannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeFullWidthPortraitWithHeight(50.0f)];
    return _adMobBannerView;
}

- (UIView *)bannerView {
    return self.adMobBannerView;
}

#pragma mark - ALAdNetworkBannerAdapter

- (void)configure:(AMNetworkConfiguration *)networkConfiguration bannerView:(AMBannerView *)bannerView {
    self.adMobBannerView.rootViewController = bannerView.rootViewController;
    self.adMobBannerView.adUnitID = networkConfiguration.AdMobAdUnitId;
    self.adMobBannerView.delegate = self;
}

- (void)loadBanner {
    GADRequest *request = [GADRequest request];
    AMDemographics *demographics = [AdlibClient sharedClient].demographics;
    if (demographics && demographics.location) {
        [request setLocationWithLatitude:demographics.location.coordinate.latitude longitude:demographics.location.coordinate.longitude accuracy:500];
    }
    [self.adMobBannerView loadRequest:request];
}

#pragma mark - GADBannerViewDelegate

- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    if (self.tapped) self.tapped(self, self.provider.name);
}

- (void)adViewDidReceiveAd:(GADBannerView *)view {
    if (self.completion) self.completion(YES, self, self.provider.name);
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    if (self.completion) self.completion(NO, self, self.provider.name);
}

@end
