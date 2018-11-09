//
//  ALTapEvent.h
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTLModel.h"
#import "MTLJSONAdapter.h"
#import "AMAd.h"
#import "AMProvider.h"

@interface AMTapEvent : MTLModel <MTLJSONSerializing>
@property (nonatomic, assign) AMAdType adType;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, assign) NSString *network;
@property (nonatomic, assign) NSString *appId;
@property (nonatomic, copy) NSString *unitId;
@property (nonatomic, strong) NSNumber *campaignId;

@end
