//
//  AMAppLovinNetworkBannerAdapter.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMAppLovinBannerAdapter.h"
#import "AMNetworkConfiguration.h"
#import <ALSdk.h>
#import <ALAdView.h>
#import <ALAdSize.h>
#import <ALAdLoadDelegate.h>

//FYI Banners are now deprecated for AppLovin

@interface AMAppLovinBannerAdapter() <ALAdLoadDelegate, ALAdDisplayDelegate>
@property (nonatomic, strong) ALAdView *appLovinBannerView;
@end

@implementation AMAppLovinBannerAdapter
@synthesize provider = _provider;
@synthesize completion = _completion;
@synthesize tapped = _tapped;
@synthesize forceAPINext = _forceAPINext;

#pragma mark - Properties

- (UIView *)bannerView {
    return self.appLovinBannerView;
}

#pragma mark - ALAdNetworkBannerAdapter

- (void)configure:(AMNetworkConfiguration *)networkConfiguration bannerView:(AMBannerView *)bannerView {
    ALSdk *appLovinSDK = [ALSdk sharedWithKey:networkConfiguration.AppLovinSdkKey];
    [appLovinSDK initializeSdk];

    self.appLovinBannerView = [[ALAdView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 50.0f) size:[ALAdSize sizeBanner] sdk:appLovinSDK];
    self.appLovinBannerView.adLoadDelegate = self;
    self.appLovinBannerView.adDisplayDelegate = self;
}

- (void)loadBanner {
    [self.appLovinBannerView loadNextAd];
}

#pragma mark - ALAdLoadDelegate

-(void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad {
    if (self.completion) self.completion(YES, self, self.provider.name);
}

-(void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code {
    if (self.completion) self.completion(NO, self, self.provider.name);
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view {
    if (self.tapped) self.tapped(self, self.provider.name);
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view {
}

- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view {
}

@end
