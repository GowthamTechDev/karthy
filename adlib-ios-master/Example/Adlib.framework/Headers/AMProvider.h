//
//  AMProvider.h
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMNetworkConfiguration;
@class AMAdQuery;
@class AMDemographics;

@protocol AMProviderBannerAdapter, AMProviderInterstitialAdapter;

typedef NS_ENUM(NSUInteger, AMProviderType) {
    AMProviderTypeAdlib = 0,
    AMProviderTypeInMobi = 1,
    AMProviderTypeAdMob = 2,
    AMProviderTypeGreystripe = 3,
    AMProviderTypeAppLovin = 4,
    AMProviderTypePhunware = 5,
    AMProviderTypeStartApp = 6
};

NSString *NSStringFromAMProviderType(AMProviderType providerType);
id<AMProviderInterstitialAdapter> AMAdProviderInterstitialAdapterFromAMProviderType(AMProviderType providerType);
id<AMProviderBannerAdapter> AMAdProviderBannerAdapterFromAMProviderType(AMProviderType providerType);


typedef NS_ENUM(NSUInteger, AMProviderBannerType) {
    AMProviderBannerTypeBanner = 0,
    AMProviderBannerTypeVideo = 1,
    AMProviderBannerTypeBoth = 2
};
NSString *NSStringFromAMProviderBannerType(AMProviderBannerType bannerType);


typedef NS_ENUM(NSUInteger, AMProviderInterstitialType) {
    AMProviderInterstitialTypeInterstitial = 0,
    AMProviderInterstitialTypeVideo = 1,
    AMProviderInterstitialTypeBoth = 2
};
NSString *NSStringFromAMProviderInterstitialType(AMProviderInterstitialType interstitialType);

AMProviderType AMProviderTypeForNetworkName(NSString *networkName);

/**
 *  Provides information about an ad network provider.  For each provider,
 *  override this class.
 */
@interface AMProvider : NSObject
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) AMProviderType type;
@property (nonatomic, readonly) AMProviderBannerType bannerType;
@property (nonatomic, readonly) AMProviderInterstitialType interstitialType;

/**
 *  Override this method to provide any extra steps needed to configure the providers SDK.
 *
 *  @param networkConfiguration Network configuration info passed from the portal.
 */
- (void)configure:(AMNetworkConfiguration *)networkConfiguration;

/**
 *  Override this method to pass demographics changes in the `AdlibClient` to the provider's SDK.
 *
 *  @param demographics <#demographics description#>
 */
- (void)configureDemographics:(AMDemographics *)demographics;

/**
 *  Creates and returns an adapter for displaying ads in an `AMBannerView`.
 *
 *  @return <#return value description#>
 */
- (id<AMProviderBannerAdapter>)bannerAdapterWithProvider;


/**
 *  Creates and returns an adapter for displaying ads in an `AMInterstitialView`.
 *
 *  @return <#return value description#>
 */
- (id<AMProviderInterstitialAdapter>)interstitialAdapterWithProvider;

- (BOOL)enabled;

@end
