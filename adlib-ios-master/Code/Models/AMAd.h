//
//  ALAd.h
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@class AMAd;
@class AMDemographics;
@class AMTapEvent;
@class AMRegisterEvent;

typedef void(^AMAdLoadBlock)(AMAd *ad);
typedef void(^AMAdEventBlock)(BOOL success);
typedef NS_ENUM(NSUInteger, AMAdType) {
    AMAdTypeBanner = 0,
    AMAdTypeVideo = 1,
    AMAdTypeInterstitial = 2
};
NSString *NSStringFromAMAdType(AMAdType adType);

@interface AMAd : MTLModel <MTLJSONSerializing>
@property (nonatomic, copy) NSString *network;
@property (nonatomic, assign) BOOL force;
@property (nonatomic, strong) NSURL *clickURL;
@property (nonatomic, strong) NSURL *adURL;
@property (nonatomic, copy) NSString *adType;
@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) NSString *beaconURL;
@property (nonatomic, readonly) CGSize size;

+ (void)loadAdWithAppId:(NSString *)appId adType:(AMAdType)adType unitId:(NSString *)unitId campaignId:(NSNumber *)campaignId demographics:(AMDemographics *)demographics completion:(AMAdLoadBlock)completion;
+ (void)loadAdWithSize:(CGSize)size AppId:(NSString *)appId adType:(NSString*)adType unitId:(NSString *)unitId campaignId:(NSNumber *)campaignId demographics:(AMDemographics *)demographics completion:(AMAdLoadBlock)completion;
+ (void)trackTapEvent:(AMTapEvent *)tapEvent completion:(AMAdEventBlock)completion;
+ (void)trackRegisterAd:(AMRegisterEvent *)registerEvent completion:(AMAdEventBlock)completion;

@end
