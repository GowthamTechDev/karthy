//
//  ALAPIBannerViewDelegate.h
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMAPIBannerView;

@protocol AMAPIBannerViewDelegate

- (void)APIBannerViewDidReceiveAd:(AMAPIBannerView *)bannerView;
- (void)APIBannerViewFailedToReceiveAd:(AMAPIBannerView *)bannerView;
- (void)APIBannerViewDidTapBanner:(AMAPIBannerView *)bannerView;

@end
