//
//  AMInterstitialLoader.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMInterstitialLoader.h"
#import "AMMacros.h"
#import "AdlibClient.h"
#import "AMNetworkConfiguration.h"
#import "AMAdUnit.h"
#import "AMAd.h"
#import "AMCampaign.h"
#import "AMCampaignTarget.h"
#import "AMProvider.h"
#import "AMAPIInterstitialView.h"
#import "AMAPIInterstitialViewAdapter.h"
#import "AMRegisterEvent.h"
#import "AMProviderInterstitialAdapter.h"

@interface AMInterstitialLoader()
@property (nonatomic, strong) id<AMProviderInterstitialAdapter> loadedInterstitialAdapter;
@property (nonatomic, assign) NSUInteger firstLoadFailCount;
@property (nonatomic, strong) AMAd *ad;
@property (nonatomic, strong) AMAPIInterstitialView *loadedApiInterstitialView;
@property (nonatomic, readwrite, strong) AMCampaign *campaign;

@end

@implementation AMInterstitialLoader

#pragma mark - Initializer

- (instancetype)initWithAdlibClient:(AdlibClient *)client {
    self = [super init];
    if (self) {
        _client = client;
    }
    return self;
}

#pragma mark - Interstitial loading

- (void)loadInterstitialWithProviders:(NSSet *)providers adUnit:(AMAdUnit *)adUnit success:(AMInterstitialLoaderSuccessBlock)success failure:(AMInterstitialLoaderFailureBlock)failure {
    if (!success) {
        return;
    }
    
    //NSLog(@"Calling load Intersitial with providers");
    
    self.loading = YES;
    self.loadedInterstitialAdapter = nil;
    self.ad = nil;
    
    self.campaign = [adUnit randomCampaignWithMatchingDemographics:self.client.demographics];
    NSNumber *campaignId = self.campaign ? @(self.campaign.campaignId) : nil;
    
    AMWeakSelf weakSelf = self;
    [AMAd loadAdWithAppId:self.client.appId adType:2 unitId:adUnit.adUnitId campaignId:campaignId demographics:self.client.demographics completion:^(AMAd *ad) {
        if (ad) {
            weakSelf.ad = ad;
            if (ad.force) {
                // Ad is forced, display Adlib's ad
                //NSLog(@"Ad is forced, display Adlib's ad with %@", NSStringFromClass([weakSelf.rootViewController class]));

                [self loadAdWithAPIProvider:ad adapters:providers success:success failure:failure];
                
                [weakSelf trackInterstitialLoad:ad.network beacon:ad.beaconURL]; 
            } else if (weakSelf.campaign) {
                // Load a Interstitial in the campaign.
                //NSLog(@"Load interstitial in the campaign");
                [weakSelf loadInterstitialByCampaignWithProviders:providers campaign:weakSelf.campaign success:success failure:failure];
            } else {
                // There are no matching campaigns, load the first served Interstitial.
                [weakSelf loadFirstServedInterstitialWithProviders:providers success:success failure:failure];
               // NSLog(@"There are no matching campaigns, load the first served Interstitial.");
            }
        } else if (failure) {
            failure();
        }
    }];
}

- (void)loadInterstitialByCampaignWithProviders:(NSSet *)adapters campaign:(AMCampaign *)campaign success:(AMInterstitialLoaderSuccessBlock)success failure:(AMInterstitialLoaderFailureBlock)failure {
    // find the campaign's matching targets.
    NSArray *matchingTargets = [campaign.targets filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(AMCampaignTarget *target, NSDictionary *bindings) {
        return [target hasMatchingDemographics:self.client.demographics];
    }]];
    
    // order by priority ascending.
    matchingTargets = [matchingTargets sortedArrayUsingComparator:^NSComparisonResult(AMCampaignTarget *target1, AMCampaignTarget *target2) {
        NSUInteger priority1 = target1.priority;
        NSUInteger priority2 = target2.priority;
        if (priority1 < priority2) {
            return NSOrderedAscending;
        }
        if (priority1 > priority2) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    
    NSMutableArray *matchingAdapters = [NSMutableArray new];
    for (AMCampaignTarget *matchingTarget in matchingTargets) {
       // NSLog(@"Matching target %@", matchingTarget.network);
        NSSet *matchingAdapter = [adapters filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSObject<AMProviderInterstitialAdapter> *adapter, NSDictionary *bindings) {
          //  NSLog(@"Matching adapter %@", matchingTarget.network);
            return adapter.provider.type == AMProviderTypeForNetworkName(matchingTarget.network);
        }]];

        if ([matchingAdapter count] > 0) {
            [matchingAdapters addObject:matchingAdapter.anyObject];
        }
    }
    
    NSTimeInterval timeout = campaign.timeout ? 10 : [campaign.timeout doubleValue];
    [self startLoadingMatchingProviders:matchingAdapters timeout:timeout success:success failure:failure];
}

- (void)startLoadingMatchingProviders:(NSArray *)matchingAdapters timeout:(NSTimeInterval)timeout success:(AMInterstitialLoaderSuccessBlock)success failure:(AMInterstitialLoaderFailureBlock)failure {
    __block BOOL completed = NO;
    __block BOOL canceled = NO;
    if ([matchingAdapters count] > 0) {
        NSObject<AMProviderInterstitialAdapter> *currentAdapter = matchingAdapters[0];

        NSMutableArray *nextMatchingAdapters = [matchingAdapters mutableCopy];
        [nextMatchingAdapters removeObjectAtIndex:0];
        
        if([self.ad.network isEqualToString:@"Failed"] || [currentAdapter.provider.name isEqualToString:@"Failed"])
        {
            failure();
            return;
        }

        AMWeakSelf weakSelf = self;
        currentAdapter.completion = ^(BOOL successful, id<AMProviderInterstitialAdapter> InterstitialAdapter, NSString *networkName) {
            if (canceled) {
                return;
            }
            
            if (successful) {
                if (!weakSelf.loadedInterstitialAdapter) {
                    weakSelf.loadedInterstitialAdapter = InterstitialAdapter;
                    weakSelf.loadedInterstitialAdapter.rootViewController = self.rootViewController;
                    success(InterstitialAdapter.interstitialView, networkName);
                    
                    [weakSelf trackInterstitialLoad:networkName beacon:nil];
                }
            } else {
                //NSLog(@"Loading not successful from %@", weakSelf.loadedInterstitialAdapter.provider.name);
                [weakSelf startLoadingMatchingProviders:nextMatchingAdapters timeout:timeout success:success failure:failure];
            }
            completed = YES;
        };
        
       // NSLog(@"Loading Matching Provider %@", currentAdapter.provider.name);
        [currentAdapter loadInterstitial];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, timeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            if (!completed) {
                // Loading Interstitial has timed out, load the next one if it exists.
                canceled = YES;
                [weakSelf startLoadingMatchingProviders:nextMatchingAdapters timeout:timeout success:success failure:failure];
               // NSLog(@"Loading Interstitial has timed out, load the next one if it exists.");
            }
        });
        
    } else if (failure) {
        failure();
    }
}

- (void)loadFirstServedInterstitialWithProviders:(NSSet *)adapters success:(AMInterstitialLoaderSuccessBlock)success failure:(AMInterstitialLoaderFailureBlock)failure {
    self.firstLoadFailCount = 0;
    self.loadedInterstitialAdapter = nil;
    
    AMWeakSelf weakSelf = self;
    for (NSObject<AMProviderInterstitialAdapter> *adapter in adapters) {
        adapter.completion = ^(BOOL successful, id<AMProviderInterstitialAdapter> InterstitialAdapter, NSString *networkName) {
            if (successful && ([networkName isEqualToString:@"Failed"] == false)) {
                if (!weakSelf.loadedInterstitialAdapter) {
                    weakSelf.loadedInterstitialAdapter = InterstitialAdapter;
                    success(InterstitialAdapter.interstitialView, networkName);
                    
                    [weakSelf trackInterstitialLoad:networkName beacon:nil];
                }
            } else {
                weakSelf.firstLoadFailCount = weakSelf.firstLoadFailCount + 1;
                if (weakSelf.firstLoadFailCount == [adapters count] && failure) {
                    failure();
                }
            }
        };
        
        [adapter loadInterstitial];
    }
}

- (void)trackInterstitialLoad:(NSString *)networkName beacon:(NSString *)beacon {
    AMRegisterEvent *registerEvent = [AMRegisterEvent new];
    registerEvent.impression = true;
    registerEvent.network = networkName;
    registerEvent.adType = AMAdTypeInterstitial;
    registerEvent.beaconURL = beacon;
    if (self.campaign) {
        registerEvent.campaignId = @(self.campaign.campaignId);
    }
    
    [AMAd trackRegisterAd:registerEvent completion:nil];
}

- (void)showCurrentLoadedInterstitial:(AMInterstitialShowSuccessBlock)success failure:(AMInterstitialShowFailureBlock)failure;
{
    AMWeakSelf weakSelf = self;
    NSObject<AMProviderInterstitialAdapter> *adapter = weakSelf.loadedInterstitialAdapter;
    
    
    adapter.show = ^(BOOL successful, id<AMProviderInterstitialAdapter> InterstitialAdapter, NSString *networkName)
    {
        if (successful) {
            success(networkName);
        }
        else {
            failure();
        }
    };

    if([self checkIfAPIForceLocal:weakSelf.ad.network]) {
       // NSLog(@"Showing API interstitial with %@", NSStringFromClass([weakSelf.rootViewController class]));
    } else {
        //NSLog(@"Showing sdk interstitial");
    }
    
    if(weakSelf.ad.force)
    {
       // NSLog(@"Loader trying to show forced ad with adapter: %@", adapter.provider.name);
        adapter.rootViewController = self.rootViewController;
        [adapter showInterstitial];
    }
    else
    {
       // NSLog(@"Loader showig with adapter: %@", weakSelf.loadedInterstitialAdapter.provider.name);
        adapter.rootViewController = self.rootViewController;
        [adapter showInterstitial];
    }

}


- (void)loadAdWithAPIProvider:(AMAd *)ad adapters:(NSSet *)adapters success:(AMInterstitialLoaderSuccessBlock)success failure:(AMInterstitialLoaderFailureBlock)failure
{
    AMWeakSelf weakSelf = self;
    NSObject<AMProviderInterstitialAdapter> *apiAdapter = nil;
    
    for (NSObject<AMProviderInterstitialAdapter> *adapter in adapters) {
        if(adapter.provider.type == AMProviderTypeAdlib)
        {
            apiAdapter = adapter;
            break;
        }
    }

    apiAdapter.completion = ^(BOOL successful, id<AMProviderInterstitialAdapter> InterstitialAdapter, NSString *networkName) {
        if (successful) {
            weakSelf.loadedInterstitialAdapter = InterstitialAdapter;
            success(InterstitialAdapter.interstitialView, networkName);
            
            [weakSelf trackInterstitialLoad:networkName beacon:nil];
        }
        else {
            failure();
        }
        
    };
    
    apiAdapter.rootViewController = weakSelf.rootViewController;
    [apiAdapter loadInterstitial];
}


-(BOOL)checkIfAPIForceLocal:(NSString*)networkName
{
    if([networkName isEqualToString:@"Appia"] ||
       [networkName isEqualToString:@"mMedia"] ||
       [networkName isEqualToString:@"PubNative"] ||
       [networkName isEqualToString:@"Smaato"] ||
       [networkName isEqualToString:@"Default"] ||
       [networkName isEqualToString:@"Force"] ||
       [networkName isEqualToString:@"Local"])
    {
        return true;
    }
    else
    {
        return false;
    }
    
}

@end
