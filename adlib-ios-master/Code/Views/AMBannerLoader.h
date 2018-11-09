//
//  AMBannerLoader.h
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@class AdlibClient;
@class AMAdUnit;
@class AMCampaign;

typedef void(^AMBannerLoaderSuccessBlock)(UIView *view, NSString *networkName);
typedef void(^AMBannerLoaderFailureBlock)();

/**
 *  `AMBannerLoader` is responsible for loading banners from the various networks.
 */
@interface AMBannerLoader : NSObject
@property (nonatomic, strong) AdlibClient *client;
@property (nonatomic, copy) NSString *unitId;
@property (nonatomic, readonly) AMCampaign *campaign;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) CGSize size;

- (instancetype)initWithAdlibClient:(AdlibClient *)client;

- (void)loadBannerWithProviders:(NSSet *)providers adUnit:(AMAdUnit *)adUnit success:(AMBannerLoaderSuccessBlock)success failure:(AMBannerLoaderFailureBlock)failure;

@end
