//
//  ALAdQuery.h
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMDemographics.h"
#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@class CLLocation;
@class AMDemographics;

@interface AMAdQuery : MTLModel <MTLJSONSerializing>
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, assign) AMDemographicsGender gender;
@property (nonatomic, copy) NSString *zip;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, assign) AMDemographicsMaritalStatus maritalStatus;
@property (nonatomic, strong) NSNumber *income;
@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, copy) NSString *country;

+ (instancetype)adQueryWithDemographics:(AMDemographics *)demographics;

@end
