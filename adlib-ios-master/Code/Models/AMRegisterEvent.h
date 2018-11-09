//
//  ALRegisterEvent.h
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTLModel.h"
#import "MTLJSONAdapter.h"
#import "AMAd.h"
#import "AMProvider.h"

@interface AMRegisterEvent : MTLModel <MTLJSONSerializing>
@property (nonatomic, assign) AMAdType adType;
@property (nonatomic, copy) NSString *app;
@property (nonatomic, copy) NSNumber *campaignId;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *deviceModel;
@property (nonatomic, copy) NSString *deviceOS;
@property (nonatomic, assign) BOOL impression;
@property (nonatomic, copy) NSString *network;
@property (nonatomic, assign) NSString *appId;
@property (nonatomic, copy) NSString *unitId;
@property (nonatomic, copy) NSString *beaconURL;
@property (nonatomic, assign) NSString *country;

@end
