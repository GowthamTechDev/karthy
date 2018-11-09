//
//  AMInMobiProvider.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMInMobiProvider.h"
#import "AMNetworkConfiguration.h"
#import "AMDemographics.h"
#import "IMSdk.h"
#import "IMCommonConstants.h"


@interface AMInMobiProvider()
@property (nonatomic, assign) BOOL enabled;

@end

@implementation AMInMobiProvider

#pragma mark - Properties

- (AMProviderType)type {
    return AMProviderTypeInMobi;
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
    self.enabled = networkConfiguration.InMobiAccountId && [networkConfiguration.InMobiAccountId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0;
    
    if (!self.enabled) {
        return;
    }
    
    [IMSdk setLogLevel:kIMSDKLogLevelNone];
    [IMSdk initWithAccountID:networkConfiguration.InMobiSiteid];
}

- (void)configureDemographics:(AMDemographics *)demographics {
    
    if (demographics.age) {
        [IMSdk setAge:[demographics.age unsignedIntegerValue]];
    }
    
    switch (demographics.gender) {
        case AMDemographicsGenderUndefined:
            //Gender unkonwn deprecated in 5.3.0
            //[IMSdk setGender:kIMGenderUnknown];
            break;
        case AMDemographicsGenderMale:
            [IMSdk setGender:kIMSDKGenderMale];
            break;
        case AMDemographicsGenderFemale:
            [IMSdk setGender:kIMSDKGenderFemale];
            break;
    }
    
    if (demographics.zip) {
        [IMSdk setPostalCode:demographics.zip];
    }
    
    //Marital Status deprecated in 5.3.0
    /*switch (demographics.maritalStatus) {
        case AMDemographicsMaritalStatusMarried:
            [IMSdk setMaritalStatus:kIMMaritalStatusSingle];
            break;
        case AMDemographicsMaritalStatusSingle:
            [IMSdk setMaritalStatus:kIMMaritalStatusSingle];
            break;
        case AMDemographicsMaritalStatusUndefined:
            [IMSdk setMaritalStatus:kIMMaritalStatusUnknown];
            break;
    } */
    
    if (demographics.income) {
        [IMSdk setIncome:[demographics.income unsignedIntValue]];
    }
}

@end
