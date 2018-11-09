//
//  AMCampaignTarget.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMCampaignTarget.h"
#import "AMDemographics.h"
#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"

@implementation AMCampaignTarget

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"priority": @"priority",
        @"ageFrom": @"age_from",
        @"ageTo": @"age_to",
        @"network": @"network",
        @"geo": @"geo",
        @"gender": @"gender",
    };
}

+ (NSValueTransformer *)genderJSONTransformer {
    NSDictionary *genders = @{
        @"": @(AMDemographicsGenderUndefined),
        @"male": @(AMDemographicsGenderMale),
        @"female": @(AMDemographicsGenderFemale)
    };
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:genders defaultValue:@(AMDemographicsMaritalStatusUndefined) reverseDefaultValue:@""];
}

#pragma mark - 

- (BOOL)hasMatchingDemographics:(AMDemographics *)demographics {
    if ([self.ageFrom unsignedIntegerValue]>0 || [self.ageTo unsignedIntegerValue]>0) {
        NSUInteger age = [demographics.age unsignedIntegerValue];
        if (self.ageFrom && age < [self.ageFrom unsignedIntegerValue]) {
            return NO;
        }
        if (self.ageTo && (age > [self.ageTo unsignedIntegerValue] || [self.ageTo unsignedIntegerValue] == 0)) {
            return NO;
        }
    }
    if (self.gender != AMDemographicsGenderUndefined) {
        if (self.gender != demographics.gender) {
            return NO;
        }
    }
    if (self.geo && [self.geo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        if (![[demographics.country lowercaseString] isEqualToString:[self.geo lowercaseString]]) {
            return NO;
        }
    }
    return YES;
}

@end
