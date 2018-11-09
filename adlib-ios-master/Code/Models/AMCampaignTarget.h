//
//  AMCampaignTarget.h
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTLModel.h"
#import "MTLJSONAdapter.h"
#import "AMProvider.h"
#import "AMDemographics.h"

@interface AMCampaignTarget : MTLModel <MTLJSONSerializing>
@property (nonatomic, assign) NSUInteger priority;
@property (nonatomic, strong) NSNumber *ageFrom;
@property (nonatomic, strong) NSNumber *ageTo;
@property (nonatomic, copy) NSString *network;
@property (nonatomic, copy) NSString *geo;
@property (nonatomic, assign) AMDemographicsGender gender;

- (BOOL)hasMatchingDemographics:(AMDemographics *)demographics;

@end
