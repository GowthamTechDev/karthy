//
//  AMHTTPClient.h
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface AMHTTPClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end
