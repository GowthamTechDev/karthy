//
//  ALAPIBannerViewAdapter.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMAPIBannerViewAdapter.h"
#import "AMAPIBannerView.h"
#import "AMAd.h"

@interface AMAPIBannerViewAdapter() <AMAPIBannerViewDelegate>
@property (nonatomic, strong) AMAPIBannerView *apiBannerView;

@end

@implementation AMAPIBannerViewAdapter
@synthesize provider = _provider;
@synthesize completion = _completion;
@synthesize tapped = _tapped;
@synthesize forceAPINext = _forceAPINext;

#pragma mark - Properties

- (AMAPIBannerView *)apiBannerView {
    if (_apiBannerView) {
        return _apiBannerView;
    }
    _apiBannerView = [[AMAPIBannerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 50.0f)];
    _apiBannerView.delegate = self;
    return _apiBannerView;
}

- (UIView *)bannerView {
    return self.apiBannerView;
}

#pragma mark - ALAdNetworkBannerAdapter

- (void)configure:(AMNetworkConfiguration *)networkConfiguration bannerView:(AMBannerView *)bannerView {
    self.apiBannerView.unitId = bannerView.unitId;
}

- (void)loadBanner {
    [self.apiBannerView loadBanner];
}

#pragma mark - ALAPIBannerViewDelegate

- (void)APIBannerViewDidReceiveAd:(AMAPIBannerView *)bannerView {
    self.forceAPINext = bannerView.ad.force;
    
    if (self.completion) self.completion(YES, self, bannerView.ad.network);
}

- (void)APIBannerViewFailedToReceiveAd:(AMAPIBannerView *)bannerView {
    if (self.completion) self.completion(NO, self, self.provider.name);
}

- (void)APIBannerViewDidTapBanner:(AMAPIBannerView *)bannerView {
    if (self.tapped) self.tapped(self, bannerView.ad.network);
}

@end
