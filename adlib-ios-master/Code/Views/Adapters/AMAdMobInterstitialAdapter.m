//
//  ALAdMobInterstitialViewAdapter.m
//  Adlib
//
//  Copyright (c) 2016 Adlib Mediation. All rights reserved.
//

#import "AMAdMobInterstitialAdapter.h"
#import "AMNetworkConfiguration.h"
#import "AdlibClient.h"
#import "AMDemographics.h"
#import <GoogleMobileAds/GADInterstitial.h>
#import <GoogleMobileAds/GADInterstitialDelegate.h>
#import <CoreLocation/CoreLocation.h>

@import GoogleMobileAds;

@interface AMAdMobInterstitialAdapter() <GADInterstitialDelegate>
@property (nonatomic, strong) GADInterstitial *adMobInterstitialView;
@property (nonatomic, strong) NSString *currentUnitId;

@end

@implementation AMAdMobInterstitialAdapter
@synthesize provider = _provider;
@synthesize completion = _completion;
@synthesize show = _show;
@synthesize tapped = _tapped;
@synthesize dismissed = _dismissed;
@synthesize forceAPINext = _forceAPINext;
@synthesize rootViewController = _rootViewController;

#pragma mark - Properties

- (GADInterstitial *)adMobInterstitialView {
    if (_adMobInterstitialView) {
        return _adMobInterstitialView;
    }
    _adMobInterstitialView = [[GADInterstitial alloc] initWithAdUnitID:@""];
    return _adMobInterstitialView;
} 

- (NSObject *)interstitialView {
    return self.adMobInterstitialView;
}

#pragma mark - ALAdNetworkInterstitialAdapter

- (void)configure:(AMNetworkConfiguration *)networkConfiguration interstitialView:(AMInterstitialView *)interstitialView {
    self.rootViewController = interstitialView.rootViewController;
    //self.adMobInterstitialView.rootViewController = interstitialView.rootViewController;
    self.currentUnitId = networkConfiguration.AdMobAdUnitIdInterstitial;
    self.adMobInterstitialView = [[GADInterstitial alloc] initWithAdUnitID:networkConfiguration.AdMobAdUnitIdInterstitial];
    self.adMobInterstitialView.delegate = self;
}

- (void)loadInterstitial {
    GADRequest *request = [GADRequest request];
    AMDemographics *demographics = [AdlibClient sharedClient].demographics;
    if (demographics && demographics.location) {
        [request setLocationWithLatitude:demographics.location.coordinate.latitude longitude:demographics.location.coordinate.longitude accuracy:500];
    }

    [self.adMobInterstitialView loadRequest:request];
}

- (void)showInterstitial {
    if([self.adMobInterstitialView isReady]){
        [self.adMobInterstitialView presentFromRootViewController:self.rootViewController];
    }
    else {
        if (self.show) self.show(NO, self, self.provider.name);
    }
}

#pragma mark - GADInterstitialDelegate

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    if (self.tapped) self.tapped(self, self.provider.name);
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    if (self.completion) self.completion(YES, self, self.provider.name);
}

-(void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    if (self.show) self.show(YES, self, self.provider.name);
}

-(void)interstitialDidFailToPresentScreen:(GADInterstitial *)ad {
    if (self.show) self.show(NO, self, self.provider.name);
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    if (self.completion) self.completion(NO, self, self.provider.name);
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    if (self.dismissed) self.dismissed(self, self.provider.name);
    self.adMobInterstitialView =  nil;
    self.adMobInterstitialView.delegate = nil;
    
    GADInterstitial *interstitial = [[GADInterstitial alloc] initWithAdUnitID:self.currentUnitId];
    self.adMobInterstitialView = interstitial;
    self.adMobInterstitialView.delegate = self;
}

@end
