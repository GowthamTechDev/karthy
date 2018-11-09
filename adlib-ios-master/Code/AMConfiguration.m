//
//  AMConfiguration.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMConfiguration.h"

#ifndef AM_BETA
#define AM_BETA 0
#endif

#ifndef AM_STAGING
#define AM_STAGING 0
#endif

#ifndef AM_PRODUCTION
#define AM_PRODUCTION 0
#endif


@implementation AMConfiguration

#pragma mark - Initializer

+ (instancetype)sharedConfiguration {
    static AMConfiguration *_sharedConfiguration = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedConfiguration = [AMConfiguration new];
    });
    return _sharedConfiguration;
};

#pragma mark - Properties

- (AMConfigurationEnvironment)environment {
    if ([@(AM_BETA) boolValue]) {
        return AMConfigurationEnvironmentBeta;
    } else if ([@(AM_STAGING) boolValue]) {
        return AMConfigurationEnvironmentStaging;
    } else if ([@(AM_PRODUCTION) boolValue]) {
        return AMConfigurationEnvironmentProduction;
    }
    return AMConfigurationEnvironmentProduction;
}

- (NSURL *)APIURL {
    switch (self.environment) {
        case AMConfigurationEnvironmentStaging: return [NSURL URLWithString:@"https://mediate.evs.adlibmediation.com/v1"];
        case AMConfigurationEnvironmentBeta: return [NSURL URLWithString:@"https://mediate.beta.adlibmediation.com/v1"];
        case AMConfigurationEnvironmentProduction: return [NSURL URLWithString:@"https://mediate.beta.adlibmediation.com/v1"];
    }
}

@end
