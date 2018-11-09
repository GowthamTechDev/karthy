//
//  ALAdNetworkInterstitialAdapter.h
//  Adlib
//
//  Copyright (c) 2016 Adlib Mediation. All rights reserved.
//

@import UIKit;
#import <Foundation/Foundation.h>
#import "AMProvider.h"
#import "AMInterstitialView.h"

@protocol AMProviderInterstitialAdapter;
@class AMNetworkConfiguration;

typedef void(^AMProviderInterstitialAdapterLoadBlock)(BOOL success, id<AMProviderInterstitialAdapter> interstitialAdapter, NSString *networkName);
typedef void(^AMProviderInterstitialAdapterViewShowBlock)(BOOL success, id<AMProviderInterstitialAdapter> interstitialAdapter, NSString *networkName);
typedef void(^AMProviderInterstitialAdapterViewTappedBlock)(id<AMProviderInterstitialAdapter> interstitialAdapter, NSString *networkName);
typedef void(^AMProviderInterstitialAdapterViewDismissedBlock)(id<AMProviderInterstitialAdapter> interstitialAdapter, NSString *networkName);

@protocol AMProviderInterstitialAdapter <NSObject>
@property (nonatomic, readonly) UIView *interstitialView;
@property (nonatomic, weak) AMProvider *provider;
@property (nonatomic, copy) AMProviderInterstitialAdapterLoadBlock completion;
@property (nonatomic, copy) AMProviderInterstitialAdapterViewShowBlock show;
@property (nonatomic, copy) AMProviderInterstitialAdapterViewTappedBlock tapped;
@property (nonatomic, copy) AMProviderInterstitialAdapterViewDismissedBlock dismissed;
@property (nonatomic, strong) UIViewController *rootViewController;
@property (nonatomic, assign) BOOL forceAPINext;

- (void)configure:(AMNetworkConfiguration *)networkConfiguration interstitialView:(AMInterstitialView *)interstitialView;
- (void)loadInterstitial;
- (void)showInterstitial;

@end
