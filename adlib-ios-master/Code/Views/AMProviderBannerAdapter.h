//
//  ALAdNetworkBannerAdapter.h
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

@import UIKit;
#import <Foundation/Foundation.h>
#import "AMProvider.h"
#import "AMBannerView.h"

@protocol AMProviderBannerAdapter;
@class AMNetworkConfiguration;

typedef void(^AMProviderBannerAdapterLoadBlock)(BOOL success, id<AMProviderBannerAdapter> bannerAdapter, NSString *networkName);
typedef void(^AMProviderBannerAdapterViewTappedBlock)(id<AMProviderBannerAdapter> bannerAdapter, NSString *networkName);

@protocol AMProviderBannerAdapter <NSObject>
@property (nonatomic, readonly) UIView *bannerView;
@property (nonatomic, weak) AMProvider *provider;
@property (nonatomic, copy) AMProviderBannerAdapterLoadBlock completion;
@property (nonatomic, copy) AMProviderBannerAdapterViewTappedBlock tapped;
@property (nonatomic, assign) BOOL forceAPINext;

- (void)configure:(AMNetworkConfiguration *)networkConfiguration bannerView:(AMBannerView *)bannerView;
- (void)loadBanner;

@end
