//
//  ALAPIBannerView.h
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMAPIBannerViewDelegate.h"
#import "AMProviderBannerAdapter.h"

@class AMNetworkConfiguration;
@class AMAd;

@interface AMAPIBannerView : UIView
@property (nonatomic, weak) id <AMAPIBannerViewDelegate> delegate;
@property (nonatomic, copy) NSString *unitId;
@property (nonatomic, strong) AMAd *ad;

- (void)loadBanner;
- (void)loadBannerWithAd:(AMAd *)ad;

@end
