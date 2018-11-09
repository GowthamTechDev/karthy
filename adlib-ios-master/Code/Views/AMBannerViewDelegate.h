//
//  ALBannerViewDelegate.h
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMProvider.h"

@class AMBannerView;

@protocol AMBannerViewDelegate <NSObject>

@optional

/**
 *  Called when an ad network provider returns an ad.
 *
 *  @param bannerView  Banner view that loaded an ad.
 *  @param networkName Name of the network ad belongs to.
 */
- (void)bannerView:(AMBannerView *)bannerView didReceiveBannerWithNetwork:(NSString *)networkName;

/**
 *  Called when an ad network provider fails to return an ad.
 *
 *  @param bannerView Banner view with error
 *  @param error      NSError object with description of error.
 */
- (void)bannerViewFailedToLoadBanner:(AMBannerView *)bannerView error:(NSError *)error;

/**
 *  Called when a banner has been tapped.
 *
 *  @param bannerView  Banner view that was tapped.
 *  @param networkName Name of the network that was tapped.
 */
- (void)bannerView:(AMBannerView *)bannerView didTapBannerViewWithNetwork:(NSString *)networkName;

@end
