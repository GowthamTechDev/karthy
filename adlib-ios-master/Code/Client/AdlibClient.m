//
//  ALAdlibClient.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AdlibClient.h"
#import "AMMacros.h"
#import "AMNetworkConfiguration.h"
#import "AMNetworkConfigurationManager.h"
#import "AMClientConfiguration.h"
#import "AMAdQuery.h"
#import "AMAdUnit.h"
#import "AMProvider.h"
#import "AMAdMobProvider.h"
#import "AMAdlibProvider.h"
#import "AMAppLovinProvider.h"
#import "AMGreystripeProvider.h"
#import "AMInMobiProvider.h"
#import "AMPhunwareProvider.h"
#import "AMStartAppProvider.h"

NSString *const AdlibClientStartedNotification = @"ALAdlibClientStartedNotification";
NSString *const AdlibClientDemographicsKey = @"AdlibClientDemographicsKey";

@interface AdlibClient() <CLLocationManagerDelegate>
@property (nonatomic, readwrite, strong) AMAdUnit *adUnit;
@property (nonatomic, readwrite, strong) AMDemographics *demographics;
@property (nonatomic, assign) BOOL started;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, strong) NSArray *allProviders;
@property (nonatomic, readwrite, strong) NSArray *availableProviders;
@property (nonatomic, readwrite, strong) NSSet *currentProviders;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation AdlibClient

#pragma mark - Properties

- (void)setAvailableProviders:(NSArray *)availableProviders {
    _availableProviders = availableProviders;
    if (availableProviders) {
        self.currentProviders = [NSSet setWithArray:availableProviders];
    } else {
        self.currentProviders = nil;
    }
}

- (NSArray *)currentUnitIds {
    AMNetworkConfiguration *networkConfiguration = [AMNetworkConfigurationManager sharedManager].networkConfiguration;
    if (!networkConfiguration) {
        return @[];
    }
    return networkConfiguration.unitIds;
}

#pragma mark - Initializer

+ (instancetype)sharedClient {
    static AdlibClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [AdlibClient new];
    });
    return _sharedClient;
};

- (instancetype)init {
    self = [super init];
    if (self) {
        self.demographics = [AMDemographics new];
        [self setupProviders];
        [self addObserver:self forKeyPath:@"demographics" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }

    return self;
}

- (void)setupProviders {
    self.allProviders = @[
        [AMAdMobProvider new],
        [AMAdlibProvider new],
        [AMAppLovinProvider new],
        [AMGreystripeProvider new],
        [AMInMobiProvider new],
        [AMPhunwareProvider new],
        [AMStartAppProvider new]
    ];
}

- (void)startWithAppId:(NSString *)appId delegate:(id<AdlibClientDelegate>)delegate {
    self.delegate = delegate;
    self.appId = appId;
    
    [self connect];
}

- (void)connect {
    AMWeakSelf weakSelf = self;
    [AMNetworkConfiguration loadByAppId:self.appId completion:^(AMNetworkConfiguration *networkConfiguration) {
        [AMNetworkConfigurationManager sharedManager].networkConfiguration = networkConfiguration;
        
        if (networkConfiguration) {
            NSMutableArray *availableProviders = [NSMutableArray new];
            for (AMProvider *provider in weakSelf.allProviders) {
                [provider configure:networkConfiguration];
                if ([provider enabled]) {
                   // NSLog(@"Adding Provider %@", provider.name);
                    [availableProviders addObject:provider];
                }
            }
            weakSelf.availableProviders = availableProviders;
            weakSelf.started = YES;
            
            if ([self.delegate respondsToSelector:@selector(adlibClientDidStart:)]) {
                [self.delegate adlibClientDidStart:weakSelf];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:AdlibClientStartedNotification object:nil];
        } else {
            weakSelf.started = NO;
            
            if ([self.delegate respondsToSelector:@selector(adlibClientFailedToStart:)]) {
                [self.delegate adlibClientFailedToStart:weakSelf];
            }
        }
    }];
}

- (void)startWithAppId:(NSString *)appId {
    [self startWithAppId:appId delegate:nil];
}

#pragma mark - Configuration

- (void)setAge:(NSNumber *)age {
    AMDemographics *demographics = self.demographics;
    demographics.age = age;
    self.demographics = demographics;
}

- (void)setGender:(AMDemographicsGender)gender {
    AMDemographics *demographics = self.demographics;
    demographics.gender = gender;
    self.demographics = demographics;
}

- (void)setZip:(NSString *)zip {
    AMDemographics *demographics = self.demographics;
    demographics.zip = zip;
    self.demographics = demographics;
}

- (void)setLocation:(CLLocation *)location {
    [self setLocationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
}

- (void)setLocationWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
    AMDemographics *demographics = self.demographics;
    demographics.latitude = @(latitude);
    demographics.longitude = @(longitude);
    [self reverseGeoCodeLatitude:latitude longitude:longitude];
    self.demographics = demographics;
}

- (void)setCountry:(NSString *)country {
    AMDemographics *demographics = self.demographics;
    demographics.country = country;
    self.demographics = demographics;
}

- (void)setMaritalStatus:(AMDemographicsMaritalStatus)maritalStatus {
    AMDemographics *demographics = self.demographics;
    demographics.maritalStatus = maritalStatus;
    self.demographics = demographics;
}

- (void)setIncome:(NSNumber *)income {
    AMDemographics *demographics = self.demographics;
    demographics.income = income;
    self.demographics = demographics;
}

- (void)updateLocation {
    [self startTrackingLocation];
}

- (void)updateProviderDemographics {
    for (AMProvider *provider in self.allProviders) {
        [provider configureDemographics:self.demographics];
    }
}

- (void)setProvider:(AMProviderType)providerType enabled:(BOOL)enabled {
    if (enabled) {
        NSArray *matchingProviders = [self.availableProviders filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(AMProvider *provider, NSDictionary *bindings) {
            return provider.type == providerType;
        }]];
        if (matchingProviders && [matchingProviders count] > 0) {
            NSMutableSet *currentProviders = [self.currentProviders mutableCopy];
            [currentProviders addObject:matchingProviders[0]];
            self.currentProviders = currentProviders;
        }
    } else {
        if (providerType == AMProviderTypeAdlib) {
            return;
        }
        self.currentProviders = [self.currentProviders filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(AMProvider *provider, NSDictionary *bindings) {
            return provider.type != providerType;
        }]];
    }
}

- (BOOL)isProviderEnabled:(AMProviderType)providerType {
    NSSet *matchingProvider = [self.currentProviders filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(AMProvider *provider, NSDictionary *bindings) {
        return provider.type == providerType;
    }]];
    return matchingProvider && [matchingProvider count] > 0;
}

#pragma mark - Location tracking

- (void)startTrackingLocation {
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
}

- (void)stopTrackingLocation {
    if (self.locationManager) {
        [self.locationManager startUpdatingLocation];
        self.locationManager = nil;
    }
}

- (void)reverseGeoCodeLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    [self reverseGEOCodeLocation:location];
}

- (void)reverseGEOCodeLocation:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error && placemarks && [placemarks count] > 0) {
            CLPlacemark *placemark = placemarks[0];
            [self setCountry:placemark.country];
        }
    }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (locations && [locations count] > 0) {
        CLLocation *location = [locations lastObject];
        [self setLocation:location];
        [self reverseGEOCodeLocation:location];
        [self stopTrackingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // TODO: Handle error.
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"demographics"]) {
        [self updateProviderDemographics];
    }
}

@end
