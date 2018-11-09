//
//  ALNetworkConfiguration.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMNetworkConfiguration.h"
#import "AMAdUnit.h"
#import "AMHTTPClient.h"

@implementation AMNetworkConfiguration

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"appId": @"ids.adlib|app_id",
        @"userId": @"ids.adlib|user_id",
        @"AdMobAdUnitId": @"ids.AdMob|AdUnitId",
        @"AdMobAdUnitIdInterstitial": @"ids.AdMob|AdUnitIdInterstitial",
        @"AppiaPlacementId": @"ids.Appia|placementId",
        @"AppiaPlacementIdInterstitial": @"ids.Appia|placementIdInterstitial",
        @"AppiaSiteId": @"ids.Appia|siteId",
        @"AppiaPassword": @"ids.Appia|password",
        @"AppiaId": @"ids.Appia|id",
        @"ConversantAppId": @"ids.Conversant|AppId",
        @"InMobiSiteid": @"ids.InMobi|siteid",
        @"InMobiAccountId" : @"ids.InMobi|accountId",
        @"InMobiPlacementIdInterstitial" : @"ids.InMobi|placementIdInterstitial",
        @"MMediaApid": @"ids.MMedia|apid",
        @"MMediaApidInterstitial": @"ids.MMedia|apidInterstitial",
        @"PubNativeAppToken": @"ids.PubNative|app_token",
        @"PubNativeBundleId": @"ids.PubNative|bundle_id",
        @"SMAATOAdspaceInterstitial": @"ids.SMAATO|adspaceInterstitial",
        @"SMAATOAdspace": @"ids.SMAATO|adspace",
        @"SMAATOPub": @"ids.SMAATO|pub",
        @"PhunwareSiteId": @"ids.Phunware|SiteID",
        @"PhunwareZoneId": @"ids.Phunware|ZoneID",
        @"AppLovinSdkKey": @"ids.AppLovin|SdkKey",
        @"StartAppAppID": @"ids.StartApp|AppID",
        @"StartAppAccountID": @"ids.StartApp|AccountID",
        @"units": @"units"
    };
}

+ (NSValueTransformer *)unitsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[AMAdUnit class]];
}

#pragma mark - Properties

- (NSArray *)unitIds {
    if (self.units) {
        NSMutableArray *unitIds = [NSMutableArray new];
        for (AMAdUnit *unit in self.units) {
            [unitIds addObject:unit.adUnitId];
        }
        return unitIds;
    }
    return nil;
}

#pragma mark -

- (AMAdUnit *)adUnitWithAdUnitId:(NSString *)adUnitId {
    if (self.units && adUnitId) {
        for (AMAdUnit *adUnit in self.units) {
            if ([adUnit.adUnitId isEqualToString:adUnitId]) {
                return adUnit;
            }
        }
    }
    return nil;
}

#pragma mark - CRUD

+ (void)loadByAppId:(NSString *)appId completion:(AMNetworkConfigurationLoadBlock)completion {
    NSString *path = [NSString stringWithFormat:@"ids/%@", appId];
    [[AMHTTPClient sharedClient] GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *serializationError = nil;
        AMNetworkConfiguration *networkConfiguration = [MTLJSONAdapter modelOfClass:[AMNetworkConfiguration class] fromJSONDictionary:responseObject[@"values"] error:&serializationError];
        if (serializationError) {
            NSLog(@"Error serializing network configuration: %@", serializationError);
        }
        if (completion) {
            completion(networkConfiguration);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error loading network configuration: %@", error);
        if (completion) {
            completion(nil);
        }
    }];
}

@end
