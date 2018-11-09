//
//  ALAdQuery.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMAdQuery.h"
#import <CoreLocation/CoreLocation.h>
#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"

@implementation AMAdQuery

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"age": @"age",
        @"gender": @"gender",
        @"zip": @"zip",
        @"latitude": @"lat",
        @"longitude": @"lon",
        @"country": @"country",
        @"maritalStatus": @"marital_status",
        @"income": @"income"
    };
}

+ (NSValueTransformer *)maritalStatusJSONTransformer {
    NSDictionary *maritalStatuses = @{
        @"undefined": @(AMDemographicsMaritalStatusUndefined),
        @"married": @(AMDemographicsMaritalStatusMarried),
        @"unmarried": @(AMDemographicsMaritalStatusSingle)
    };
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:maritalStatuses defaultValue:@(AMDemographicsMaritalStatusUndefined) reverseDefaultValue:@"undefined"];
}

+ (NSValueTransformer *)genderJSONTransformer {
    NSDictionary *genders = @{
        @"": @(AMDemographicsGenderUndefined),
        @"male": @(AMDemographicsGenderMale),
        @"female": @(AMDemographicsGenderFemale)
    };
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:genders defaultValue:@(AMDemographicsMaritalStatusUndefined) reverseDefaultValue:@""];
}

#pragma mark - Initializer

+ (instancetype)adQueryWithDemographics:(AMDemographics *)demographics {
    AMAdQuery *query = [[AMAdQuery alloc] initWithDemographics:demographics];
    return query;
}

- (instancetype)initWithDemographics:(AMDemographics *)demographics {
    self = [super init];
    if (self && demographics) {
        _age = demographics.age;
        _gender = demographics.gender;
        _zip = demographics.zip;
        _latitude = demographics.latitude;
        _longitude = demographics.longitude;
        _maritalStatus = demographics.maritalStatus;
        _income = demographics.income;
        _country = demographics.country;
    }
    return self;
}

#pragma mark - Properties

- (CLLocation *)location {
    if (self.latitude && self.longitude) {
        return [[CLLocation alloc] initWithLatitude:[self.latitude doubleValue] longitude:[self.longitude doubleValue]];
    }
    return nil;
}

@end
