//
//  AMCampaign.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMCampaign.h"
#import "AMCampaignTarget.h"

@implementation AMCampaign

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
         @"campaignId": @"id",
         @"name": @"name",
         @"timeout": @"timeout",
         @"targets": @"targets"
     };
}

+ (NSValueTransformer *)targetsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[AMCampaignTarget class]];
}

@end
