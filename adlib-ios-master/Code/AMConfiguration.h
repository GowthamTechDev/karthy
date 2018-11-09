//
//  AMConfiguration.h
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AMConfigurationEnvironment) {
    AMConfigurationEnvironmentProduction = 0,
    AMConfigurationEnvironmentStaging = 1,
    AMConfigurationEnvironmentBeta = 2
};

/**
 *  `AMConfiguration` manages build time configuration through preprocessor macros
 *  set in various build configurations.
 */
@interface AMConfiguration : NSObject
@property (nonatomic, readonly) AMConfigurationEnvironment environment;
@property (nonatomic, readonly) NSURL *APIURL;

+ (instancetype)sharedConfiguration;

@end
