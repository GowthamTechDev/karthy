//
//  ALAd.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMAd.h"
#import "AMHTTPClient.h"
#import "AMAdQuery.h"
#import "AMTapEvent.h"
#import "AMRegisterEvent.h"
#import "AdlibClient.h"
#import "AMNetworkConfiguration.h"
#import "AMAdUnit.h"
#import <AdSupport/AdSupport.h>

NSString *NSStringFromAMAdType(AMAdType adType) {
    switch (adType) {
        case AMAdTypeBanner:
            return @"Banner";
        case AMAdTypeVideo:
            return @"Video";
        case AMAdTypeInterstitial:
            return @"Interstitial";
    }
}

@implementation AMAd

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"network": @"network",
        @"force": @"force",
        @"clickURL": @"ad.clickUrl",
        @"adURL": @"ad.adUrl",
        @"adType": @"ad.adType",
        @"height": @"ad.height",
        @"width": @"ad.width",
        @"beaconURL": @"ad.extra.beacon.url"
    };
}

#pragma mark - Properites

- (CGSize)size {
    CGFloat width = self.width ? [self.width doubleValue] : 320.0f;
    CGFloat height = self.height ? [self.height doubleValue] : 50.0f;
    return CGSizeMake(width, height);
}

#pragma mark - CRUD

+ (void)loadAdWithAppId:(NSString *)appId adType:(AMAdType)adType unitId:(NSString *)unitId campaignId:(NSNumber *)campaignId demographics:(AMDemographics *)demographics completion:(AMAdLoadBlock)completion {
    NSString *loadedAdType = (adType == AMAdTypeBanner) ? @"b" : @"i";
    [self loadAdWithSize:CGSizeZero AppId:appId adType:loadedAdType unitId:unitId campaignId:campaignId demographics:demographics completion:completion];
}

+ (void)loadAdWithSize:(CGSize)size AppId:(NSString *)appId adType:(NSString*)adType unitId:(NSString *)unitId campaignId:(NSNumber *)campaignId demographics:(AMDemographics *)demographics completion:(AMAdLoadBlock)completion {
    NSString *path = [NSString stringWithFormat:@"ad/%@/%@/%@", adType, appId, [[UIDevice currentDevice].identifierForVendor UUIDString]];
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        path = [path stringByAppendingPathComponent:@(size.width).stringValue];
        path = [path stringByAppendingPathComponent:@(size.height).stringValue];
    }
    ASIdentifierManager *identifierManager = [ASIdentifierManager sharedManager];
    NSMutableDictionary *parameters = [@{
        @"ad_unit_id": unitId ?: @"",
        @"campaign_id": campaignId ?: @0,
        @"advertising_id": [identifierManager.advertisingIdentifier UUIDString],
        @"do_not_track": identifierManager.advertisingTrackingEnabled ? @"false" : @"true"
    } mutableCopy];
    if (demographics) {
        AMAdQuery *query = [AMAdQuery adQueryWithDemographics:demographics];
        [parameters addEntriesFromDictionary:[MTLJSONAdapter JSONDictionaryFromModel:query error:nil]];
    }
    [[AMHTTPClient sharedClient] GET:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *serializationError = nil;
        AMAd *ad = [MTLJSONAdapter modelOfClass:[AMAd class] fromJSONDictionary:responseObject error:&serializationError];
        if (serializationError) {
            NSLog(@"Error serializing ad: %@", serializationError);
        }
        if (completion) {
            completion(ad);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error finding ad: %@", error);
        if (completion) {
            completion(nil);
        }
    }];
}

+ (void)trackTapEvent:(AMTapEvent *)tapEvent completion:(AMAdEventBlock)completion {
    if (!tapEvent) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    tapEvent.appId = [AdlibClient sharedClient].appId;
    
    NSError *serializationError = nil;
    NSDictionary *parameters = [MTLJSONAdapter JSONDictionaryFromModel:tapEvent error:nil];
    if (serializationError) {
        NSLog(@"Error serializing tap event: %@", serializationError);
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    [[AMHTTPClient sharedClient] POST:@"register_click" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            BOOL success = responseObject[@"success"] && [responseObject[@"success"] boolValue];
            completion(success);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error sending tap event: %@", error);
        if (completion) {
            completion(NO);
        }
    }];
}

+ (void)trackRegisterAd:(AMRegisterEvent *)registerEvent completion:(AMAdEventBlock)completion {
    if (!registerEvent) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    AdlibClient *client = [AdlibClient sharedClient];
    registerEvent.appId = client.appId;
    registerEvent.country = client.demographics.country;
    
    NSError *serializationError = nil;
    NSDictionary *parameters = [MTLJSONAdapter JSONDictionaryFromModel:registerEvent error:&serializationError];
    if (serializationError) {
        NSLog(@"Error serializing register event: %@", serializationError);
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    if ([registerEvent.network isEqualToString:@"Default"]) {
        NSMutableDictionary *mutableParameters = [parameters mutableCopy];
        mutableParameters[@"default"] = @"true";
        parameters = [mutableParameters copy];
    }
    
    if ([registerEvent.network isEqualToString:@"Failed"]) {
        NSMutableDictionary *mutableParameters = [parameters mutableCopy];
        mutableParameters[@"failed"] = @"true";
        parameters = [mutableParameters copy];
    }
    
    [[AMHTTPClient sharedClient] POST:@"register_ad" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            BOOL success = responseObject[@"success"] && [responseObject[@"success"] boolValue];
            completion(success);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error sending register event: %@", error);
        if (completion) {
            completion(NO);
        }
    }];
    
    if (registerEvent.beaconURL) {
        [[AMHTTPClient sharedClient] GET:registerEvent.beaconURL parameters:nil success:nil failure:nil];
    }
}

@end
