//
//  AMStartAppBannerViewAdapter.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMStartAppBannerAdapter.h"
#import "AMNetworkConfiguration.h"
#import "AdlibClient.h"
#import "AMClientConfiguration.h"
#import <StartApp/StartApp.h>

@interface AMStartAppBannerAdapter() <STABannerDelegateProtocol>
@property (nonatomic, strong) STABannerView *startAppBannerView;

@end

@implementation AMStartAppBannerAdapter
@synthesize provider = _provider;
@synthesize completion = _completion;
@synthesize tapped = _tapped;
@synthesize forceAPINext = _forceAPINext;

#pragma mark - Properties

- (UIView *)bannerView {
    return self.startAppBannerView;
}

#pragma mark - ALAdNetworkBannerAdapter

- (void)configure:(AMNetworkConfiguration *)networkConfiguration bannerView:(AMBannerView *)bannerView {
    self.startAppBannerView = [[STABannerView alloc] initWithSize:STA_AutoAdSize origin:CGPointZero withView:bannerView withDelegate:self];
}

- (void)loadBanner {
    [self.startAppBannerView showBanner];
}

#pragma mark - STABannerDelegateProtocol

- (void)didDisplayBannerAd:(STABannerView*)banner {
    if (self.completion) self.completion(YES, self, self.provider.name);
}

- (void)failedLoadBannerAd:(STABannerView*)banner withError:(NSError *)error {
    if (self.completion) self.completion(NO, self, self.provider.name);
}

- (void)didClickBannerAd:(STABannerView*)banner {
    if (self.tapped) self.tapped(self, self.provider.name);
}

@end
