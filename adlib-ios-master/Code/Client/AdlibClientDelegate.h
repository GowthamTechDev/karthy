//
//  AMAdlibClientDelegate.h
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AdlibClient;

/**
 *  The `AdlibClientDelegate` defines global delegate methods for events within
 *  the Adlib SDK.
 */
@protocol AdlibClientDelegate <NSObject>

@optional

/**
 *  This method is called when the `AdlibClient` has finished initialization and 
 *  is started.
 *
 *  @param adlibClient Current client.
 */
- (void)adlibClientDidStart:(AdlibClient *)adlibClient;

/**
 *  Called when the `AdlibClient` has failed to start because of connectivity 
 *  issues.  If this is called, try to connect again using `[adlibClient connect:]`.
 *
 *  @param adlibClient Current client.
 */
- (void)adlibClientFailedToStart:(AdlibClient *)adlibClient;

/**
 *  Global delegate call when an `AMBannerView` received a banner.
 *
 *  @param adlibClient Current client.
 *  @param networkName Name of network that loaded.
 */
- (void)adlibClient:(AdlibClient *)adlibClient didReceiveBannerWithNetwork:(NSString *)networkName;

/**
 *  Global delegate call when a banner view was tapped.
 *
 *  @param adlibClient Current client.
 *  @param networkName Name of network that was tapped.
 */
- (void)adlibClient:(AdlibClient *)adlibClient didTapBannerWithNetwork:(NSString *)networkName;

/**
 *  Global delegate call when an `AMInterstitialView` received an interstitial.
 *
 *  @param adlibClient Current client.
 *  @param networkName Name of network that loaded.
 */
- (void)adlibClient:(AdlibClient *)adlibClient didReceiveInterstitialWithNetwork:(NSString *)networkName;

/**
 *  Global delegate call when an `AMInterstitialView` showed an interstitial.
 *
 *  @param adlibClient Current client.
 *  @param networkName Name of network that showed.
 */
- (void)adlibClient:(AdlibClient *)adlibClient didShowInterstitialWithNetwork:(NSString *)networkName;

/**
 *  Global delegate call when a interstitial view was tapped.
 *
 *  @param adlibClient Current client.
 *  @param networkName Name of network that was tapped.
 */
- (void)adlibClient:(AdlibClient *)adlibClient didTapInterstitialWithNetwork:(NSString *)networkName;

/**
 *  Global delegate call when a interstitial view was dismissed.
 *
 *  @param adlibClient Current client.
 *  @param networkName Name of network that was dismissed.
 */
- (void)adlibClient:(AdlibClient *)adlibClient didDismissInterstitialWithNetwork:(NSString *)networkName;

@end
