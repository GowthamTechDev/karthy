//
//  AMAdUnit.h
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@class AMCampaign;
@class AMDemographics;

@interface AMAdUnit : MTLModel <MTLJSONSerializing>
@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, copy) NSString *adType;
@property (nonatomic, strong) NSNumber *refreshTime;
@property (nonatomic, assign) BOOL strictSize;
@property (nonatomic, strong) NSArray *campaigns;

- (AMCampaign *)randomCampaignWithMatchingDemographics:(AMDemographics *)adQuery;

@end
