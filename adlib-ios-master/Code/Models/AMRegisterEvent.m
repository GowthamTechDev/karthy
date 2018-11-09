//
//  ALRegisterEvent.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMRegisterEvent.h"
#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"

@implementation AMRegisterEvent

#pragma mark - Initializer

- (instancetype)init {
    self = [super init];
    if (self) {
        _app = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
        _deviceId = [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    return self;
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"adType": @"ad_type",
        @"app": @"app",
        @"campaignId": @"campaign_id",
        @"deviceId": @"device_id",
        @"impression": @"impression",
        @"network": @"network",
        @"appId": @"app_id",
        @"unitId": @"ad_unit_id",
        @"country": @"country"
    };
}

+ (NSValueTransformer *)adTypeJSONTransformer {
    NSDictionary *adTypes = @{
        NSStringFromAMAdType(AMAdTypeBanner): @(AMAdTypeBanner),
        NSStringFromAMAdType(AMAdTypeVideo): @(AMAdTypeVideo),
        NSStringFromAMAdType(AMAdTypeInterstitial): @(AMAdTypeInterstitial)
    };
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:adTypes];
}

@end
