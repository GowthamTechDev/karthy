//
//  AMNetworkConfigurationManager.h
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMNetworkConfiguration.h"

/**
 *  Gives global access to the `AMNetworkConfiguration` object returned
 *  from the portal while hiding implementation details in the framework's 
 *  public header files.
 */
@interface AMNetworkConfigurationManager : NSObject
@property (nonatomic, strong) AMNetworkConfiguration *networkConfiguration;

+ (instancetype)sharedManager;

@end
