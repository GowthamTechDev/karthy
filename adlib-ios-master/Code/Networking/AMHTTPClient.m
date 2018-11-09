//
//  ALHTTPClient.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMHTTPClient.h"
#import "AMConfiguration.h"

@implementation AMHTTPClient

+ (instancetype)sharedClient {
    static AMHTTPClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[AMHTTPClient alloc] initWithBaseURL:[AMConfiguration sharedConfiguration].APIURL];
    });
    return sharedClient;
}

@end
