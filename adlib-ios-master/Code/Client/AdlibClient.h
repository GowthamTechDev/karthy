//
//  ALAdlibClient.h
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AMDemographics.h"
#import "AMProvider.h"
#import "AdlibClientDelegate.h"

@class AMClientConfiguration;
@class AMAdUnit;

extern NSString *const AdlibClientStartedNotification;

@interface AdlibClient : NSObject
@property (nonatomic, readonly) AMDemographics *demographics;
@property (nonatomic, readonly) BOOL started;
@property (nonatomic, readonly, copy) NSString *appId;
@property (nonatomic, weak) id<AdlibClientDelegate> delegate;
@property (nonatomic, readonly) NSArray *availableProviders;
@property (nonatomic, readonly) NSSet *currentProviders;
@property (nonatomic, readonly) NSArray *currentUnitIds;

+ (instancetype)sharedClient;

/**
 *  Initializes and starts the Adlib mediator client with the provided App ID
 *  obtained in the Adlib portal.
 *
 *  @param appId    Adlib app id.
 *  @param delegate Global delegate.
 */
- (void)startWithAppId:(NSString *)appId delegate:(id<AdlibClientDelegate>)delegate;

/**
 *  Initializes and starts the Adlib mediator client with the provided App ID 
 *  obtained in the Adlib portal.
 *
 *  @param appId  Adlib app id.
 */
- (void)startWithAppId:(NSString *)appId;

/**
 *  Use this method to try to connect to the Adlib REST API if there is an issue
 *  connecting using the `startWithAppId:` method.
 */
- (void)connect;

- (void)setAge:(NSNumber *)age;
- (void)setGender:(AMDemographicsGender)gender;
- (void)setZip:(NSString *)zip;
- (void)setMaritalStatus:(AMDemographicsMaritalStatus)maritalStatus;
- (void)setIncome:(NSNumber *)income;
- (void)setLocation:(CLLocation *)location;
- (void)setLocationWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;
- (void)setCountry:(NSString *)country;

/**
 *  Uses CoreLocation to find the current location of the device and deliver 
 *  more relevant ads to the user.  In accordance to Apple's guidelines, only 
 *  use location tracking if it is already being used to enhance the app and not
 *  soley for advertising purposes.
 */
- (void)updateLocation;

/**
 *  Enable or disable network providers by type.  `AMProviderTypeAdlib` can't be 
 *  disabled.
 *
 *  @param providerType Network provider type.
 *  @param enabled      Filter boolean.
 */
- (void)setProvider:(AMProviderType)providerType enabled:(BOOL)enabled;

/**
 *  Determines if a provider type is enabled.
 *
 *  @param providerType Type of provider.
 *
 *  @return `YES` if the the provider is enabled and available.
 */
- (BOOL)isProviderEnabled:(AMProviderType)providerType;

@end
