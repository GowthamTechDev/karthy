//
//  ALAdlibConfiguration.h
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@interface AMClientConfiguration : NSObject
@property (nonatomic, assign) BOOL enableLocationTracking;

@end
