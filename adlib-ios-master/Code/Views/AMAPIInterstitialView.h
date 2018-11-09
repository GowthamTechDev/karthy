//
//  ALAPIInterstitialView.h
//  Adlib
//
//  Copyright (c) 2016 Adlib Mediation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMAPIInterstitialViewDelegate.h"
#import "AMProviderBannerAdapter.h"

@class AMNetworkConfiguration;
@class AMAd;

@interface AMAPIInterstitialView : UIView
@property (nonatomic, weak) id <AMAPIInterstitialViewDelegate> delegate;
@property (nonatomic, strong) UIViewController *rootViewController;
@property (nonatomic, copy) NSString *unitId;
@property (nonatomic, strong) AMAd *ad;

- (void)loadInterstitial;
- (void)loadInterstitialWithAd:(AMAd *)ad;
- (void)showInterstitial;

@end
