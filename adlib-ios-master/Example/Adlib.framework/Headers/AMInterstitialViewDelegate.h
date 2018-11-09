//
//  ALInterstitialViewDelegate.h
//  Adlib
//
//  Copyright (c) 2016 Adlib Mediation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMProvider.h"

@class AMInterstitialView;

@protocol AMInterstitialViewDelegate <NSObject>

@optional

/**
 *  Called when an ad network provider returns an ad.
 *
 *  @param interstitialView  Interstitial view that loaded an ad.
 *  @param networkName Name of the network ad belongs to.
 */
- (void)interstitialView:(AMInterstitialView *)interstitialView didReceiveInterstitialWithNetwork:(NSString *)networkName;

/**
 *  Called when an ad network provider shows an ad.
 *
 *  @param interstitialView  Interstitial view that showed an ad.
 *  @param networkName Name of the network ad belongs to.
 */
- (void)interstitialView:(AMInterstitialView *)interstitialView didShowInterstitialWithNetwork:(NSString *)networkName;

/**
 *  Called when an ad network provider fails to return an ad.
 *
 *  @param interstitialView Interstitial view with error
 *  @param error      NSError object with description of error.
 */
- (void)interstitialViewFailedToLoadInterstitial:(AMInterstitialView *)interstitialView error:(NSError *)error;

/**
 *  Called when an ad network provider failed to show.
 *
 *  @param interstitialView Interstitial view with error
 *  @param error      NSError object with description of error.
 */
- (void)interstitialViewFailedToShowInterstitial:(AMInterstitialView *)interstitialView error:(NSError *)error;

/**
 *  Called when a interstitial has been tapped.
 *
 *  @param interstitialView  Interstitial view that was tapped.
 *  @param networkName Name of the network that was tapped.
 */
- (void)interstitialView:(AMInterstitialView *)interstitialView didTapInterstitialViewWithNetwork:(NSString *)networkName;

/**
 *  Called when a interstitial has been dismissed.
 *
 *  @param interstitialView  Interstitial view that was dismissed.
 *  @param networkName Name of the network that was dismissed.
 */
- (void)interstitialView:(AMInterstitialView *)interstitialView didDismissInterstitialViewWithNetwork:(NSString *)networkName;

@end
