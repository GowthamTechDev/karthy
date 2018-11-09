//
//  AMNetworkConfigurationManager.m
//  Adlib
//
//  Created by Peter Grates on 6/25/15.
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMNetworkConfigurationManager.h"

@implementation AMNetworkConfigurationManager

#pragma mark - Initializer

+ (instancetype)sharedManager {
    static AMNetworkConfigurationManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [AMNetworkConfigurationManager new];
    });
    return _sharedManager;
};

@end
