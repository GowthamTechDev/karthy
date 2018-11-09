//
//  AMDemographics.h
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;

typedef NS_ENUM(NSUInteger, AMDemographicsMaritalStatus) {
    AMDemographicsMaritalStatusUndefined = 0,
    AMDemographicsMaritalStatusMarried = 1,
    AMDemographicsMaritalStatusSingle = 2
};

typedef NS_ENUM(NSUInteger, AMDemographicsGender) {
    AMDemographicsGenderUndefined = 0,
    AMDemographicsGenderMale = 1,
    AMDemographicsGenderFemale = 2
};

@interface AMDemographics : NSObject
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, assign) AMDemographicsGender gender;
@property (nonatomic, copy) NSString *zip;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, assign) AMDemographicsMaritalStatus maritalStatus;
@property (nonatomic, strong) NSNumber *income;
@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, copy) NSString *country;

@end
