//
//  AMInMobiInterstitialViewAdapter.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMInMobiInterstitialAdapter.h"
#import "AMNetworkConfiguration.h"
#import "AdlibClient.h"
#import "AMDemographics.h"
#import "IMInterstitial.h"
#import "IMInterstitialDelegate.h"
#import "IMRequestStatus.h"
#import "IMSdk.h"
#import <CoreLocation/CoreLocation.h>

@interface AMInMobiInterstitialAdapter() <IMInterstitialDelegate>
@property (nonatomic, strong) IMInterstitial *inMobiInterstitialView;

@end

@implementation AMInMobiInterstitialAdapter
@synthesize provider = _provider;
@synthesize completion = _completion;
@synthesize show = _show;
@synthesize tapped = _tapped;
@synthesize dismissed = _dismissed;
@synthesize forceAPINext = _forceAPINext;
@synthesize rootViewController = _rootViewController;

#pragma mark - Properties

- (NSObject *)interstitialView {
    return self.inMobiInterstitialView;
}


#pragma mark - ALAdNetworkInterstitialAdapter

- (void)configure:(AMNetworkConfiguration *)networkConfiguration interstitialView:(AMInterstitialView *)interstitialView {
    self.inMobiInterstitialView = [[IMInterstitial alloc] initWithPlacementId:[networkConfiguration.InMobiPlacementIdInterstitial longLongValue]];
    self.inMobiInterstitialView.delegate = self;
    self.rootViewController = interstitialView.rootViewController;
}

- (void)loadInterstitial {
    AMDemographics *demographics = [AdlibClient sharedClient].demographics;
    if (demographics && demographics.location) {
        [IMSdk setLocation:[[CLLocation alloc]  initWithLatitude:demographics.location.coordinate.latitude longitude:demographics.location.coordinate.longitude]];
    }
    [self.inMobiInterstitialView load];
}

- (void)showInterstitial {
    if([self.inMobiInterstitialView isReady])
    {
        [self.inMobiInterstitialView showFromViewController:self.rootViewController];
    }
}

#pragma mark - IMInterstitialDelegate

- (void)interstitialDidFinishLoading:(IMInterstitial *)interstitial {
    if (self.completion) self.completion(YES, self, self.provider.name);
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToLoadWithError:(IMRequestStatus *)error {
    NSLog(@"InMobi not loaded because : %@", error.localizedDescription);
    if (self.completion) self.completion(NO, self, self.provider.name);
}

- (void)interstitial:(IMInterstitial *)interstitial didFailToPresentWithError:(IMRequestStatus *)error {
    if (self.show) self.show(NO, self, self.provider.name);
}


- (void)interstitialWillPresent:(IMInterstitial *)interstitial {

}

- (void)interstitialDidPresent:(IMInterstitial *)interstitial {
    if (self.show) self.show(YES, self, self.provider.name);
}

- (void)interstitialWillDismiss:(IMInterstitial *)interstitial {
}

- (void)interstitialDidDismiss:(IMInterstitial *)interstitial {
    if (self.dismissed) self.dismissed(self, self.provider.name);
}

- (void)userWillLeaveApplicationFromInterstitial:(IMInterstitial *)interstitial {
    if (self.tapped) self.tapped(self, self.provider.name);
}

- (void)interstitial:(IMInterstitial *)interstitial rewardActionCompletedWithRewards:(NSDictionary *)rewards {
}

- (void)interstitial:(IMInterstitial *)interstitial didInteractWithParams:(NSDictionary *)params {
}


@end
