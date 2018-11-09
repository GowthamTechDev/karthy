//
//  AMBannerLoader.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMBannerLoader.h"
#import "AMMacros.h"
#import "AdlibClient.h"
#import "AMNetworkConfiguration.h"
#import "AMAdUnit.h"
#import "AMAd.h"
#import "AMCampaign.h"
#import "AMCampaignTarget.h"
#import "AMAPIBannerView.h"
#import "AMRegisterEvent.h"
#import "AMProviderBannerAdapter.h"

@interface AMBannerLoader()
@property (nonatomic, strong) id<AMProviderBannerAdapter> loadedBannerAdapter;
@property (nonatomic, assign) NSUInteger firstLoadFailCount;
@property (nonatomic, strong) AMAd *ad;
@property (nonatomic, readwrite, strong) AMCampaign *campaign;

@end

@implementation AMBannerLoader

#pragma mark - Initializer

- (instancetype)initWithAdlibClient:(AdlibClient *)client {
    self = [super init];
    if (self) {
        _client = client;
    }
    return self;
}

#pragma mark - Banner loading

- (void)loadBannerWithProviders:(NSSet *)providers adUnit:(AMAdUnit *)adUnit success:(AMBannerLoaderSuccessBlock)success failure:(AMBannerLoaderFailureBlock)failure {
    if (!success) {
        return;
    }
    
    self.loading = YES;
    self.loadedBannerAdapter = nil;
    self.ad = nil;
    
    self.campaign = [adUnit randomCampaignWithMatchingDemographics:self.client.demographics];
    NSNumber *campaignId = self.campaign ? @(self.campaign.campaignId) : nil;
    
    AMWeakSelf weakSelf = self;
    [AMAd loadAdWithAppId:self.client.appId adType:0 unitId:adUnit.adUnitId campaignId:campaignId demographics:self.client.demographics completion:^(AMAd *ad) {
        if (ad) {
            weakSelf.ad = ad;
            if (ad.force) {
                // Ad is forced, display Adlib's ad
                AMAPIBannerView *apiBannerView = [[AMAPIBannerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, weakSelf.size.width, weakSelf.size.height)];
                [apiBannerView loadBannerWithAd:ad];
                
                success(apiBannerView, ad.network);
                
                [weakSelf trackBannerLoad:ad.network beacon:ad.beaconURL];
            } else if (weakSelf.campaign) {
                // Load a banner in the campaign.
                [weakSelf loadBannerByCampaignWithProviders:providers campaign:weakSelf.campaign success:success failure:failure];
            } else {
                // There are no matching campaigns, load the first served banner.
                [weakSelf loadFirstServedBannerWithProviders:providers success:success failure:failure];
            }
        } else if (failure) {
            failure();
        }
    }];
}

- (void)loadBannerByCampaignWithProviders:(NSSet *)adapters campaign:(AMCampaign *)campaign success:(AMBannerLoaderSuccessBlock)success failure:(AMBannerLoaderFailureBlock)failure {
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
        NSSet *matchingAdapter = [adapters filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSObject<AMProviderBannerAdapter> *adapter, NSDictionary *bindings) {
            return adapter.provider.type == AMProviderTypeForNetworkName(matchingTarget.network);
        }]];
        
        if ([matchingAdapter count] > 0) {
            [matchingAdapters addObject:matchingAdapter.anyObject];
        }
    }
    
    NSTimeInterval timeout = campaign.timeout ? 10 : [campaign.timeout doubleValue];
    [self startLoadingMatchingProviders:matchingAdapters timeout:timeout success:success failure:failure];
}

- (void)startLoadingMatchingProviders:(NSArray *)matchingAdapters timeout:(NSTimeInterval)timeout success:(AMBannerLoaderSuccessBlock)success failure:(AMBannerLoaderFailureBlock)failure {
    __block BOOL completed = NO;
    __block BOOL canceled = NO;
    if ([matchingAdapters count] > 0) {
        NSObject<AMProviderBannerAdapter> *currentAdapter = matchingAdapters[0];
        
        NSMutableArray *nextMatchingAdapters = [matchingAdapters mutableCopy];
        [nextMatchingAdapters removeObjectAtIndex:0];
        
        if (currentAdapter.provider.type == AMProviderTypeAdlib) {
            AMAPIBannerView *apiBannerView = [[AMAPIBannerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.size.width, self.size.height)];
            [apiBannerView loadBannerWithAd:self.ad];
            
            success(apiBannerView, self.ad.network);
            
            [self trackBannerLoad:self.ad.network beacon:self.ad.beaconURL];
        } else {
            AMWeakSelf weakSelf = self;
            currentAdapter.completion = ^(BOOL successful, id<AMProviderBannerAdapter> bannerAdapter, NSString *networkName) {
                if (canceled) {
                    return;
                }
                
                if (successful) {
                    if (!weakSelf.loadedBannerAdapter) {
                        weakSelf.loadedBannerAdapter = bannerAdapter;
                        success(bannerAdapter.bannerView, networkName);
                        
                        [weakSelf trackBannerLoad:networkName beacon:nil];
                    }
                } else {
                    [weakSelf startLoadingMatchingProviders:nextMatchingAdapters timeout:timeout success:success failure:failure];
                }
                completed = YES;
            };
            [currentAdapter loadBanner];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, timeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                if (!completed) {
                    // Loading banner has timed out, load the next one if it exists.
                    canceled = YES;
                    [weakSelf startLoadingMatchingProviders:nextMatchingAdapters timeout:timeout success:success failure:failure];
                }
            });
        }
    } else if (failure) {
        failure();
    }
}

- (void)loadFirstServedBannerWithProviders:(NSSet *)adapters success:(AMBannerLoaderSuccessBlock)success failure:(AMBannerLoaderFailureBlock)failure {
    self.firstLoadFailCount = 0;
    self.loadedBannerAdapter = nil;
    
    AMWeakSelf weakSelf = self;
    for (NSObject<AMProviderBannerAdapter> *adapter in adapters) {
        adapter.completion = ^(BOOL successful, id<AMProviderBannerAdapter> bannerAdapter, NSString *networkName) {
            if (successful && ([networkName isEqualToString:@"Failed"] == false)) {
                if (!weakSelf.loadedBannerAdapter) {
                    weakSelf.loadedBannerAdapter = bannerAdapter;
                    success(bannerAdapter.bannerView, networkName);
                    
                    [weakSelf trackBannerLoad:networkName beacon:nil];
                }
            } else {
                weakSelf.firstLoadFailCount = weakSelf.firstLoadFailCount + 1;
                if (weakSelf.firstLoadFailCount == [adapters count] && failure) {
                    failure();
                }
            }
        };
        
        [adapter loadBanner];
    }
}

- (void)trackBannerLoad:(NSString *)networkName beacon:(NSString *)beacon {
    AMRegisterEvent *registerEvent = [AMRegisterEvent new];
    registerEvent.impression = true;
    registerEvent.network = networkName;
    registerEvent.beaconURL = beacon;
    if (self.campaign) {
        registerEvent.campaignId = @(self.campaign.campaignId);
    }
    
    [AMAd trackRegisterAd:registerEvent completion:nil];
}

@end
