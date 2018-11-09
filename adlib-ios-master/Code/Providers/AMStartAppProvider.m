//
//  AMStartApp.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMStartAppProvider.h"
#import "AMNetworkConfiguration.h"
#import "AMDemographics.h"
#import <StartApp/StartApp.h>

@interface AMStartAppProvider()
@property (nonatomic, assign) BOOL enabled;

@end

@implementation AMStartAppProvider

#pragma mark - Properties

- (AMProviderType)type {
    return AMProviderTypeStartApp;
}

- (AMProviderBannerType)bannerType {
    return AMProviderBannerTypeBanner;
}

- (AMProviderInterstitialType)interstitialType {
    return AMProviderInterstitialTypeInterstitial;
}

- (BOOL)enabled {
    return _enabled;
}

#pragma mark - Configuration

- (void)configure:(AMNetworkConfiguration *)networkConfiguration {
    self.enabled = networkConfiguration.StartAppAccountID && [networkConfiguration.StartAppAccountID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0 && networkConfiguration.StartAppAppID && [networkConfiguration.StartAppAppID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0;
    
    if (!self.enabled) {
        return;
    }
    
    [[STAStartAppSDK sharedInstance] SDKInitialize:networkConfiguration.StartAppAccountID andAppID:networkConfiguration.StartAppAppID];
}

- (void)configureDemographics:(AMDemographics *)demographics {
    STAStartAppSDK *startAppSDK = [STAStartAppSDK sharedInstance];
    NSUInteger age = demographics.age ? [demographics.age unsignedIntegerValue] : 0;
    STAGender gender;
    switch (demographics.gender) {
        case AMDemographicsGenderUndefined:
            gender = STAGender_Undefined;
            break;
        case AMDemographicsGenderMale:
            gender = STAGender_Male;
            break;
        case AMDemographicsGenderFemale:
            gender = STAGender_Female;
            break;
    }
    startAppSDK.preferences = [STASDKPreferences prefrencesWithAge:age andGender:gender];
}

@end
