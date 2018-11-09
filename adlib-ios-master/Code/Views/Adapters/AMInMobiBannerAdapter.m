//
//  AMInMobiBannerViewAdapter.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMInMobiBannerAdapter.h"
#import "AMNetworkConfiguration.h"
#import "AdlibClient.h"
#import "AMDemographics.h"
#import "IMBanner.h"
#import "IMBannerDelegate.h"
#import "IMSdk.h"
#import "IMRequestStatus.h"
#import <CoreLocation/CoreLocation.h>

@interface AMInMobiBannerAdapter() <IMBannerDelegate>
@property (nonatomic, strong) IMBanner *inMobiBannerView;

@end

@implementation AMInMobiBannerAdapter
@synthesize provider = _provider;
@synthesize completion = _completion;
@synthesize tapped = _tapped;
@synthesize forceAPINext = _forceAPINext;

#pragma mark - Properties

- (UIView *)bannerView {
    return self.inMobiBannerView;
}


#pragma mark - ALAdNetworkBannerAdapter

- (void)configure:(AMNetworkConfiguration *)networkConfiguration bannerView:(AMBannerView *)bannerView {
    self.inMobiBannerView = [[IMBanner alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 50.0f) placementId:[networkConfiguration.InMobiSiteid longLongValue]];
    [self.inMobiBannerView shouldAutoRefresh:NO];
    self.inMobiBannerView.delegate = self;
}

- (void)loadBanner {
    AMDemographics *demographics = [AdlibClient sharedClient].demographics;
    if (demographics && demographics.location) {
        
        [IMSdk setLocation:[[CLLocation alloc]  initWithLatitude:demographics.location.coordinate.latitude longitude:demographics.location.coordinate.longitude]];
    }
    
    [self.inMobiBannerView load];
}

#pragma mark - IMBannerDelegate

- (void)bannerWillLeaveApplication:(IMBanner *)banner; {
    if (self.tapped) self.tapped(self, self.provider.name);
}

- (void)banner:(IMBanner *)banner didFailToLoadWithError:(IMRequestStatus *)error {
    if (self.completion) self.completion(NO, self, self.provider.name);
}

- (void)bannerDidReceiveAd:(IMBanner *)banner {
    if (self.completion) self.completion(YES, self, self.provider.name);
}

- (void)bannerDidFinishLoading:(IMBanner *)banner {
    NSLog(@"bannerDidFinishLoading");
}

- (void)bannerWillPresentScreen:(IMBanner *)banner{
    NSLog(@"InMobi bannerWillPresentScreen");
}

- (void)bannerDidPresentScreen:(IMBanner *)banner {
    NSLog(@"InMobi bannerDidPresentScreen");
}

- (void)bannerWillDismissScreen:(IMBanner *)banner {
    NSLog(@"InMobi bannerWillDismissScreen");
}

- (void)bannerDidDismissScreen:(IMBanner *)banner {
    NSLog(@"InMobi bannerDidDismissScreen");
}

- (void)userWillLeaveApplicationFromBanner:(IMBanner *)banner {
    NSLog(@"InMobi userWillLeaveApplicationFromBanner");
}

-(void)banner:(IMBanner *)banner didInteractWithParams:(NSDictionary *)params{
    if (self.tapped) self.tapped(self, self.provider.name);
    NSLog(@"InMobi bannerdidInteractWithParams");
}

-(void)banner:(IMBanner*)banner rewardActionCompletedWithRewards:(NSDictionary*)rewards{
    NSLog(@"InMobi rewardActionCompletedWithRewards");
}

@end
