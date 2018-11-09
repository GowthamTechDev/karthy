//
//  AMGreystripeBannerViewAdapter.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMGreystripeBannerAdapter.h"
#import "AdlibClient.h"
#import "AMNetworkConfiguration.h"
#import <GSBannerAdView.h>
#import <GSMobileBannerAdView.h>
#import <GSAdDelegate.h>


@interface AMGreystripeBannerAdapter() <GSAdDelegate>
@property (nonatomic, strong) GSMobileBannerAdView *greyStripeBannerView;
@property (nonatomic, strong) UIViewController *rootViewController;
@end

@implementation AMGreystripeBannerAdapter
@synthesize provider = _provder;
@synthesize completion = _completion;
@synthesize tapped = _tapped;
@synthesize forceAPINext = _forceAPINext;

#pragma mark - Properties

- (GSMobileBannerAdView *)greyStripeBannerView {
    if (_greyStripeBannerView) {
        return _greyStripeBannerView;
    }
    _greyStripeBannerView = [[GSMobileBannerAdView alloc] initWithDelegate:self];
    return _greyStripeBannerView;
}

- (UIView *)bannerView {
    return self.greyStripeBannerView;
}

#pragma mark - AMProviderBannerAdapter

- (void)configure:(AMNetworkConfiguration *)networkConfiguration bannerView:(AMBannerView *)bannerView {
    self.rootViewController = bannerView.rootViewController;
}

- (void)loadBanner {
    [self.greyStripeBannerView fetch];
}

#pragma mark - GSAdDelegate

- (void)greystripeAdFetchSucceeded:(id<GSAd>)a_ad {
    if (self.completion) self.completion(YES, self, self.provider.name);
}

- (void)greystripeAdFetchFailed:(id<GSAd>)a_ad withError:(GSAdError)a_error {
    if (self.completion) self.completion(NO, self, self.provider.name);
}

- (void)greystripeAdClickedThrough:(id<GSAd>)a_ad {
    if (self.tapped) self.tapped(self, self.provider.name);
}

- (UIViewController *)greystripeBannerDisplayViewController {
    return self.rootViewController;
}

@end
