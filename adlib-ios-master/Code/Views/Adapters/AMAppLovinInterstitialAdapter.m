//
//  AMAppLovinNetworkBannerAdapter.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMAppLovinInterstitialAdapter.h"
#import "AMNetworkConfiguration.h"
#import <ALSdk.h>
#import <ALInterstitialAd.h>
#import <ALAdView.h>
#import <ALAdSize.h>
#import <ALAdLoadDelegate.h>

@interface AMAppLovinInterstitialAdapter() <ALAdLoadDelegate, ALAdDisplayDelegate>
@property (nonatomic, strong) ALInterstitialAd *appLovinInterstitialView;
@end

@implementation AMAppLovinInterstitialAdapter
@synthesize provider = _provider;
@synthesize completion = _completion;
@synthesize show = _show;
@synthesize tapped = _tapped;
@synthesize dismissed = _dismissed;
@synthesize forceAPINext = _forceAPINext;
@synthesize rootViewController = _rootViewController;

#pragma mark - Properties

- (NSObject *)interstitialView {
    return self.appLovinInterstitialView;
}

#pragma mark - ALAdNetworkBannerAdapter

- (void)configure:(AMNetworkConfiguration *)networkConfiguration interstitialView:(AMInterstitialView *)interstitialView {
    ALSdk *appLovinSDK = [ALSdk sharedWithKey:networkConfiguration.AppLovinSdkKey];
    [appLovinSDK initializeSdk];
    
    self.appLovinInterstitialView = [[ALInterstitialAd alloc] initWithSdk:appLovinSDK];
    self.appLovinInterstitialView.adLoadDelegate = self;
    self.appLovinInterstitialView.adDisplayDelegate = self;
}

- (void)loadInterstitial {

}

-(void)showInterstitial {
    if([ALInterstitialAd isReadyForDisplay]) {
        [self.appLovinInterstitialView show];
    }
    else {
        if (self.show) self.show(NO, self, self.provider.name);
    }
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
    if (self.dismissed) self.dismissed(self, self.provider.name);
}

- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view {
    if (self.show) self.show(YES, self, self.provider.name);
}

@end
