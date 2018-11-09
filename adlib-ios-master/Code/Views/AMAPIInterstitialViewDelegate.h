//
//  AMAPIInterstitialViewDelegate.h
//  Adlib
//
//  Copyright (c) 2016 Adlib Mediation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMAPIInterstitialView;

@protocol AMAPIInterstitialViewDelegate

- (void)APIInterstitialViewDidReceiveAd:(AMAPIInterstitialView *)interstitialView;
- (void)APIInterstitialViewFailedToReceiveAd:(AMAPIInterstitialView *)interstitialView;
- (void)APIInterstitialViewDidShowAd:(AMAPIInterstitialView *)interstitialView;
- (void)APIInterstitialViewFailedToShowAd:(AMAPIInterstitialView *)interstitialView;
- (void)APIInterstitialViewDidTapInterstitial:(AMAPIInterstitialView *)interstitialView;
- (void)APIInterstitialViewDidDismissInterstitial:(AMAPIInterstitialView *)interstitialView;

@end
