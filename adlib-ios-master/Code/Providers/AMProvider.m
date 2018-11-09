//
//  AMProvider.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMProvider.h"
#import "AMProviderBannerAdapter.h"
#import "AMAPIBannerViewAdapter.h"
#import "AMAdMobBannerAdapter.h"
#import "AMInMobiBannerAdapter.h"
#import "AMGreystripeBannerAdapter.h"
#import "AMAppLovinBannerAdapter.h"
#import "AMPhunwareBannerAdapter.h"
#import "AMStartAppBannerAdapter.h"

#import "AMProviderInterstitialAdapter.h"
#import "AMAPIInterstitialViewAdapter.h"
#import "AMAdMobInterstitialAdapter.h"
#import "AMAppLovinInterstitialAdapter.h"
#import "AMGreystripeInterstitialAdapter.h"
#import "AMInMobiInterstitialAdapter.h"
#import "AMPhunwareInterstitialAdapter.h"
#import "AMStartAppInterstitialAdapter.h"

NSString *NSStringFromAMProviderType(AMProviderType providerType) {
    switch (providerType) {
        case AMProviderTypeAdlib: return @"Server|Inhouse|Default|Local|Failed";
        case AMProviderTypeAdMob: return @"AdMob";
        case AMProviderTypeInMobi: return @"InMobi";
        case AMProviderTypeGreystripe: return @"Greystripe";
        case AMProviderTypeAppLovin: return @"AppLovin";
        case AMProviderTypePhunware: return @"Phunware";
        case AMProviderTypeStartApp: return @"StartApp";
    }
}

id<AMProviderBannerAdapter> AMAdProviderBannerAdapterFromAMProviderType(AMProviderType providerType) {
    switch (providerType) {
        case AMProviderTypeAdlib: return [AMAPIBannerViewAdapter new];
        case AMProviderTypeAdMob: return [AMAdMobBannerAdapter new];
        case AMProviderTypeInMobi: return [AMInMobiBannerAdapter new];
        case AMProviderTypeGreystripe: return [AMGreystripeBannerAdapter new];
        case AMProviderTypeAppLovin: return [AMAppLovinBannerAdapter new];
        case AMProviderTypePhunware: return [AMPhunwareBannerAdapter new];
        case AMProviderTypeStartApp: return [AMStartAppBannerAdapter new];
    }
}

NSString *NSStringFromAMProviderBannerType(AMProviderBannerType bannerType) {
    switch (bannerType) {
        case AMProviderBannerTypeBanner: return @"Banner";
        case AMProviderBannerTypeVideo: return @"Video";
        case AMProviderBannerTypeBoth: return @"Both";
    }
}


id<AMProviderInterstitialAdapter> AMAdProviderInterstitialAdapterFromAMProviderType(AMProviderType providerType) {
    switch (providerType) {
        case AMProviderTypeAdlib: return [AMAPIInterstitialViewAdapter new];
        case AMProviderTypeAdMob: return [AMAdMobInterstitialAdapter new];
        case AMProviderTypeInMobi: return [AMInMobiInterstitialAdapter new];
        case AMProviderTypeGreystripe: return [AMGreystripeInterstitialAdapter new];
        case AMProviderTypeAppLovin: return [AMAppLovinInterstitialAdapter new];
        case AMProviderTypePhunware: return [AMPhunwareInterstitialAdapter new];
        case AMProviderTypeStartApp: return [AMStartAppInterstitialAdapter new];
        default: return nil;
    }
}

NSString *NSStringFromAMProviderInterstitialType(AMProviderInterstitialType interstitialType) {
    switch (interstitialType) {
        case AMProviderInterstitialTypeInterstitial: return @"Interstitial";
        case AMProviderInterstitialTypeVideo: return @"Video";
        case AMProviderInterstitialTypeBoth: return @"Both";
    }
}


AMProviderType AMProviderTypeForNetworkName(NSString *networkName) {
    if (!networkName) {
        return AMProviderTypeAdlib;
    }
    if ([[networkName lowercaseString] isEqualToString:@"admob"]) {
        return AMProviderTypeAdMob;
    } else if ([[networkName lowercaseString] isEqualToString:@"inmobi"]) {
        return AMProviderTypeInMobi;
    } else if ([[networkName lowercaseString] isEqualToString:@"greystripe"] || [[networkName lowercaseString] isEqualToString:@"conversant"]) {
        return AMProviderTypeGreystripe;
    } else if ([[networkName lowercaseString] isEqualToString:@"applovin"]) {
        return AMProviderTypeAppLovin;
    } else if ([[networkName lowercaseString] isEqualToString:@"phunware"]) {
        return AMProviderTypePhunware;
    } else if ([[networkName lowercaseString] isEqualToString:@"startapp"]) {
        return AMProviderTypeStartApp;
    } else if ([[networkName lowercaseString] hasPrefix:@"server"]) {
        return AMProviderTypeAdlib;
    }
    return AMProviderTypeAdlib;
}

@interface AMProvider()
@property (nonatomic, readwrite) NSString *name;

@end

@implementation AMProvider

#pragma mark - Properties

- (void)setType:(AMProviderType)type {
    _type = type;
}

- (NSString *)name {
    return NSStringFromAMProviderType(self.type);
}

- (BOOL)enabled {
    return NO;
}

#pragma mark - Configuration

- (void)configure:(AMNetworkConfiguration *)networkConfiguration {
}

- (void)configureDemographics:(AMDemographics *)demographics {
}

#pragma mark - Banner Adapter

- (id<AMProviderBannerAdapter>)bannerAdapterWithProvider {
    NSObject<AMProviderBannerAdapter> *bannerAdapter = AMAdProviderBannerAdapterFromAMProviderType(self.type);
    bannerAdapter.provider = self;
    return bannerAdapter;
}


#pragma mark - Interstitial Adapter

- (id<AMProviderInterstitialAdapter>)interstitialAdapterWithProvider {
    NSObject<AMProviderInterstitialAdapter> *interstitialAdapter = AMAdProviderInterstitialAdapterFromAMProviderType(self.type);
    interstitialAdapter.provider = self;
    return interstitialAdapter;
}

@end
