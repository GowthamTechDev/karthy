//
//  AMCampaign.h
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@interface AMCampaign : MTLModel <MTLJSONSerializing>
@property (nonatomic, assign) NSUInteger campaignId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *timeout;
@property (nonatomic, strong) NSArray *targets;

@end
