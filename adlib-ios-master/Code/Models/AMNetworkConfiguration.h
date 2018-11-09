//
//  ALNetworkConfiguration.h
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@class AMNetworkConfiguration;
@class AMAdUnit;

typedef void(^AMNetworkConfigurationLoadBlock)(AMNetworkConfiguration *networkConfiguration);

@interface AMNetworkConfiguration : MTLModel <MTLJSONSerializing>
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *AdMobAdUnitId;
@property (nonatomic, copy) NSString *AdMobAdUnitIdInterstitial;
@property (nonatomic, copy) NSString *AppiaPlacementId;
@property (nonatomic, copy) NSString *AppiaPlacementIdInterstitial;
@property (nonatomic, copy) NSString *AppiaSiteId;
@property (nonatomic, copy) NSString *AppiaPassword;
@property (nonatomic, copy) NSString *AppiaId;
@property (nonatomic, copy) NSString *ConversantAppId;
@property (nonatomic, copy) NSString *InMobiSiteid;
@property (nonatomic, copy) NSString *InMobiAccountId;
@property (nonatomic, copy) NSString *InMobiPlacementIdInterstitial;
@property (nonatomic, copy) NSString *MMediaApid;
@property (nonatomic, copy) NSString *MMediaApidInterstitial;
@property (nonatomic, copy) NSString *PubNativeAppToken;
@property (nonatomic, copy) NSString *PubNativeBundleId;
@property (nonatomic, copy) NSString *SMAATOAdspaceInterstitial;
@property (nonatomic, copy) NSString *SMAATOAdspace;
@property (nonatomic, copy) NSString *SMAATOPub;
@property (nonatomic, copy) NSString *PhunwareSiteId;
@property (nonatomic, copy) NSString *PhunwareZoneId;
@property (nonatomic, copy) NSString *AppLovinSdkKey;
@property (nonatomic, copy) NSString *StartAppAppID;
@property (nonatomic, copy) NSString *StartAppAccountID;
@property (nonatomic, strong) NSArray *units;
@property (nonatomic, readonly) NSArray *unitIds;

- (AMAdUnit *)adUnitWithAdUnitId:(NSString *)adUnitId;

+ (void)loadByAppId:(NSString *)appId completion:(AMNetworkConfigurationLoadBlock)completion;

@end
