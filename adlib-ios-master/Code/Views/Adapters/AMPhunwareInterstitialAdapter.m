//
//  AMPhunwareAdapter.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMPhunwareInterstitialAdapter.h"
#import "AMNetworkConfiguration.h"
#import "AdlibClient.h"
#import "AMClientConfiguration.h"
#import "AMDemographics.h"
#import <PWAds.h>

@interface AMPhunwareInterstitialAdapter() <PWAdsInterstitialAdDelegate>
@property (nonatomic, strong) PWAdsInterstitialAd *tapItInterstitialView;
@property (nonatomic, strong) PWAdsRequest *tapItRequest;
@property (nonatomic, assign) BOOL didLoad;
@end

@implementation AMPhunwareInterstitialAdapter
@synthesize provider = _provider;
@synthesize completion = _completion;
@synthesize show = _show;
@synthesize tapped = _tapped;
@synthesize dismissed = _dismissed;
@synthesize forceAPINext = _forceAPINext;
@synthesize rootViewController = _rootViewController;

#pragma mark - Properties

- (PWAdsInterstitialAd *)tapItInterstitialView {
    if (_tapItInterstitialView) {
        return _tapItInterstitialView;
    }
    
    _tapItInterstitialView = [[PWAdsInterstitialAd alloc] init];
    
    return _tapItInterstitialView;
}

- (NSObject *)interstitialView {
    return self.tapItInterstitialView;
}

#pragma mark - ALAdNetworkInterstitialAdapter

- (void)configure:(AMNetworkConfiguration *)networkConfiguration interstitialView:(AMInterstitialView *)interstitialView {
    if (networkConfiguration.PhunwareZoneId) {
        self.tapItRequest = [PWAdsRequest requestWithAdZone:networkConfiguration.PhunwareZoneId];
    }
    self.tapItInterstitialView.delegate = self;
    self.rootViewController = interstitialView.rootViewController;
}

- (void)loadInterstitial {
    AMDemographics *query = [AdlibClient sharedClient].demographics;
    if (query && query.location) {
        [self.tapItRequest updateLocation:query.location];
    }
    
    [self.tapItInterstitialView loadInterstitialForRequest:self.tapItRequest];
}

-(void)showInterstitial {
    if(self.didLoad) {
        [self.tapItInterstitialView presentFromViewController:self.rootViewController];
        if (self.show) self.show(YES, self, self.provider.name);
    }
    else {
        if (self.show) self.show(NO, self, self.provider.name);
    }

}

#pragma mark - TapItInterstitialAdViewDelegate

- (void)pwInterstitialAdDidLoad:(PWAdsInterstitialAd *)interstitialAd {
    self.didLoad = YES;
    if (self.completion) self.completion(YES, self, self.provider.name);
}

- (void)pwInterstitialAd:(PWAdsInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    self.didLoad = NO;
    if (self.completion) self.completion(NO, self, self.provider.name);
}

- (BOOL)pwInterstitialAdActionShouldBegin:(PWAdsInterstitialAd *)interstitialAd willLeaveApplication:(BOOL)willLeave {
    if (self.tapped) self.tapped(self, self.provider.name);
    return YES;
}

- (void)pwInterstitialAdDidUnload:(PWAdsInterstitialAd *)interstitialAd{
    self.didLoad = NO;
    if (self.dismissed) self.dismissed(self, self.provider.name);
}

@end
