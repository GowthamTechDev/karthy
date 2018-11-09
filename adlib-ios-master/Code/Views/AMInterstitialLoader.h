//
//  AMInterstitialLoader.h
//  Adlib
//
//  Copyright (c) 2016 Adlib Mediation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMProviderInterstitialAdapter.h"
@import UIKit;

@class AdlibClient;
@class AMAdUnit;
@class AMCampaign;

typedef void(^AMInterstitialLoaderSuccessBlock)(UIView *view, NSString *networkName);
typedef void(^AMInterstitialLoaderFailureBlock)();

typedef void(^AMInterstitialShowSuccessBlock)(NSString *networkName);
typedef void(^AMInterstitialShowFailureBlock)();

/**
 *  `AMInterstitialLoader` is responsible for loading interstitials from the various networks.
 */
@interface AMInterstitialLoader : NSObject
@property (nonatomic, strong) AdlibClient *client;
@property (nonatomic, copy) NSString *unitId;
@property (nonatomic, readonly) AMCampaign *campaign;
@property (nonatomic, strong) UIViewController *rootViewController;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) CGSize size;

- (instancetype)initWithAdlibClient:(AdlibClient *)client;

- (void)loadInterstitialWithProviders:(NSSet *)providers adUnit:(AMAdUnit *)adUnit success:(AMInterstitialLoaderSuccessBlock)success failure:(AMInterstitialLoaderFailureBlock)failure;

- (void)showCurrentLoadedInterstitial:(AMInterstitialShowSuccessBlock)success failure:(AMInterstitialShowFailureBlock)failure;

@end
