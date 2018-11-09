//
//  AMAdUnit.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMAdUnit.h"
#import "AMCampaign.h"
#import "AMCampaignTarget.h"
#import "MTLValueTransformer.h"

@implementation AMAdUnit

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"adUnitId": @"id",
        @"adType": @"ad_type",
        @"refreshTime": @"refresh",
        @"strictSize": @"strict",
        @"campaigns": @"campaigns"
    };
}

+ (NSValueTransformer *)campaignsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[AMCampaign class]];
}

+ (NSValueTransformer *)adUnitIdJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^NSString *(NSNumber *adUnitId, BOOL *success, NSError *__autoreleasing *error) {
        return adUnitId.stringValue;
    }];
}

+ (NSValueTransformer *)adTypeJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^NSString *(NSNumber *adType, BOOL *success, NSError *__autoreleasing *error) {
        return adType.stringValue;
    }];
}

#pragma mark - 

- (AMCampaign *)randomCampaignWithMatchingDemographics:(AMDemographics *)demographics {
    if (!self.campaigns || [self.campaigns count] == 0) {
        return nil;
    }
    NSMutableArray *matchingTargets = [NSMutableArray new];
    for (AMCampaign *campaign in self.campaigns) {
        for (AMCampaignTarget *campaignTarget in campaign.targets) {
            if ([campaignTarget hasMatchingDemographics:demographics]) {
                [matchingTargets addObject:campaign];
            }
        }
    }
    
    if ([matchingTargets count] > 0) {
        NSUInteger randomIndex = arc4random() % [matchingTargets count];
        return matchingTargets[randomIndex];
    }
    
    return nil;
}

@end
