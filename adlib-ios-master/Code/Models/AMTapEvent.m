//
//  ALTapEvent.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMTapEvent.h"
#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"

@implementation AMTapEvent

#pragma mark - Initializer

- (instancetype)init {
    self = [super init];
    if (self) {
        _deviceId = [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    return self;
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"adType": @"ad_type",
        @"deviceId": @"device_id",
        @"network": @"network",
        @"appId": @"app_id",
        @"unitId": @"ad_unit_id",
        @"campaignId": @"campaign_id"
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
