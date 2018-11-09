//
//  ALInterstitialView.m
//  Adlib
//
//  Copyright (c) 2016 Adlib Mediation. All rights reserved.
//

#import "AMInterstitialView.h"
#import "AMMacros.h"
#import "AMProvider.h"
#import "AMProviderInterstitialAdapter.h"
#import "AMAPIInterstitialViewAdapter.h"
#import "AMAdMobInterstitialAdapter.h"
#import "AMInMobiInterstitialAdapter.h"
#import "AMGreystripeInterstitialAdapter.h"
#import "AMAppLovinInterstitialAdapter.h"
#import "AMAPIInterstitialView.h"
#import "AMRegisterEvent.h"
#import "AMTapEvent.h"
#import "AdlibClient.h"
#import "AMNetworkConfiguration.h"
#import "AMNetworkConfigurationManager.h"
#import "AMAdUnit.h"
#import "AMInterstitialLoader.h"
#import "AMCampaign.h"

NSString *const AMInterstitialViewErrorDomain = @"com.adlib.error.interstitial.load";
const NSInteger AMInterstitialViewErrorLoadFailed = 1;

NSString *const AMInterstitialViewErrorDomainShow = @"com.adlib.error.interstitial.show";
const NSInteger AMInterstitialViewErrorShowFailed = 1;

@interface AMInterstitialView()
@property (nonatomic, weak) UIView *adView;
@property (nonatomic, weak) NSString *loadedAdNetWork;
@property (nonatomic, assign) BOOL interstitialsConfigured;
@property (nonatomic, assign) BOOL adRequested;
@property (nonatomic, assign) BOOL adLoaded;
@property (nonatomic, assign) BOOL forceAPINext;
@property (nonatomic, assign) NSUInteger failCount;
@property (nonatomic, strong) AMInterstitialLoader *interstitialLoader;
@property (nonatomic, strong) AdlibClient *client;
@property (nonatomic, strong) AMAdUnit *adUnit;
@property (nonatomic, strong) NSString *loadedAdNetwork;
@property (nonatomic, strong) NSSet *availableAdapters;

@end

@implementation AMInterstitialView

#pragma mark - Properties

- (void)setUnitId:(NSString *)unitId {
    _unitId = unitId;
    self.adUnit = nil;
    [self configure];
}

#pragma mark - Initializer

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.client = [AdlibClient sharedClient];
    self.interstitialLoader = [[AMInterstitialLoader alloc] initWithAdlibClient:self.client];
    self.interstitialLoader.size = self.bounds.size;
}

- (void)configure {
    self.interstitialsConfigured = NO;
    
    if (!self.client.started) {
        // Network configuration hasn't been loaded from the API yet, wait until it has to configure the Interstitial providers.
        AMWeakSelf weakSelf = self;
        __block __weak id startedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AdlibClientStartedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            [weakSelf configure];
            
            [[NSNotificationCenter defaultCenter] removeObserver:startedObserver name:nil object:nil];
        }];
        return;
    }

    self.adUnit = [[AMNetworkConfigurationManager sharedManager].networkConfiguration adUnitWithAdUnitId:self.unitId];
    if (!self.adUnit) {
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: @"Error loading interstitial, missing adUnit.  Check that the ad unit id is correct."
                                   };
        NSError *error = [NSError errorWithDomain:AMInterstitialViewErrorDomain code:AMInterstitialViewErrorLoadFailed userInfo:userInfo];
        if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialViewFailedToLoadInterstitial:error:)]) {
            [self.delegate interstitialViewFailedToLoadInterstitial:self error:error];
        }
        
        return;
    }
    
    NSMutableSet *availableAdapters = [NSMutableSet new];
    for (AMProvider *provider in self.client.availableProviders) {
        NSObject<AMProviderInterstitialAdapter> *adapter = [provider interstitialAdapterWithProvider];
        
        // Configure
        [adapter configure:[AMNetworkConfigurationManager sharedManager].networkConfiguration interstitialView:self];
        
        // Add tap callback
        AMWeakSelf weakSelf = self;
        adapter.tapped = ^(id<AMProviderInterstitialAdapter> interstitialViewAdapter, NSString *networkName) {
            [weakSelf trackTapEvent:networkName];
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(interstitialView:didTapInterstitialViewWithNetwork:)]) {
                [weakSelf.delegate interstitialView:weakSelf didTapInterstitialViewWithNetwork:networkName];
            }
            NSObject<AdlibClientDelegate> *clientDelegate = weakSelf.client.delegate;
            if (clientDelegate && [clientDelegate respondsToSelector:@selector(adlibClient:didTapInterstitialWithNetwork:)]) {
                [clientDelegate adlibClient:weakSelf.delegate didTapInterstitialWithNetwork:networkName];
            }
        };
        
        
        // Add dismiss callback
        adapter.dismissed = ^(id<AMProviderInterstitialAdapter> interstitialViewAdapter, NSString *networkName) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(interstitialView:didDismissInterstitialViewWithNetwork:)]) {
                [weakSelf.delegate interstitialView:weakSelf didDismissInterstitialViewWithNetwork:networkName];
            }
            NSObject<AdlibClientDelegate> *clientDelegate = weakSelf.client.delegate;
            if (clientDelegate && [clientDelegate respondsToSelector:@selector(adlibClient:didDismissInterstitialWithNetwork:)]) {
                [clientDelegate adlibClient:weakSelf.delegate didDismissInterstitialWithNetwork:networkName];
            }
        };

        
        [availableAdapters addObject:adapter];
    }
    self.availableAdapters = availableAdapters;
    
    self.interstitialsConfigured = YES;
    
    if (self.adRequested) {
        // Ad was requested before the interstitial was configured, load the ad.
        [self loadAd];
    }
}


#pragma mark - Actions

- (void)loadAd {
    if (!self.interstitialsConfigured) {
        self.adRequested = YES;
        return;
    }
    
    NSMutableSet *currentAdapters = [NSMutableSet new];
    for (AMProvider *provider in self.client.currentProviders) {
        NSSet *matchingAdapter = [self.availableAdapters filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSObject<AMProviderInterstitialAdapter> *adapter, NSDictionary *bindings) {
            return provider.type == adapter.provider.type;
        }]];
        [currentAdapters unionSet:matchingAdapter];
    }
    AMWeakSelf weakSelf = self;
    self.loadedAdNetWork = nil;
    self.interstitialLoader.rootViewController = self.rootViewController;
  // NSLog(@"AMIntView is loading with root %@ ", NSStringFromClass([self.root class]));
    
    
    [self.interstitialLoader loadInterstitialWithProviders:currentAdapters adUnit:self.adUnit success:^(UIView *view, NSString *networkName) {
        weakSelf.loadedAdNetwork = networkName;

        // Delegate calls
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(interstitialView:didReceiveInterstitialWithNetwork:)]) {
            [weakSelf.delegate interstitialView:weakSelf didReceiveInterstitialWithNetwork:networkName];
        }
        NSObject<AdlibClientDelegate> *clientDelegate = weakSelf.client.delegate;
        if (clientDelegate && [clientDelegate respondsToSelector:@selector(adlibClient:didReceiveInterstitialWithNetwork:)]) {
            [clientDelegate adlibClient:weakSelf.client didReceiveInterstitialWithNetwork:networkName];
        }
    } failure:^{
        if ([weakSelf.delegate respondsToSelector:@selector(interstitialViewFailedToLoadInterstitial:error:)]) {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: @"Interstitial failed to load."
                                       };
            NSError *error = [NSError errorWithDomain:AMInterstitialViewErrorDomain code:AMInterstitialViewErrorLoadFailed userInfo:userInfo];
            [weakSelf.delegate interstitialViewFailedToLoadInterstitial:weakSelf error:error];
        }
    }];
}

- (void)showAd {
    NSLog(@"Calling show ad");
    AMWeakSelf weakSelf = self;
    [self.interstitialLoader showCurrentLoadedInterstitial:^(NSString *networkName) {
        NSLog(@"Loader showing ad with network: %@", networkName);
        // Delegate calls
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(interstitialView:didShowInterstitialWithNetwork:)]) {
            [weakSelf.delegate interstitialView:weakSelf didShowInterstitialWithNetwork:networkName];
        }
        
        NSObject<AdlibClientDelegate> *clientDelegate = weakSelf.client.delegate;
        if (clientDelegate && [clientDelegate respondsToSelector:@selector(adlibClient:didShowInterstitialWithNetwork:)]) {
            [clientDelegate adlibClient:weakSelf.client didShowInterstitialWithNetwork:networkName];
        }
    } failure:^{
        if ([weakSelf.delegate respondsToSelector:@selector(interstitialViewFailedToShowInterstitial:error:)]) {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: @"Interstitial failed to show."
                                       };
            NSError *error = [NSError errorWithDomain:AMInterstitialViewErrorDomain code:AMInterstitialViewErrorLoadFailed userInfo:userInfo];
            [weakSelf.delegate interstitialViewFailedToShowInterstitial:weakSelf error:error];
        }
    }];

}


- (void)removeAd {

}

#pragma mark - Events

- (void)trackTapEvent:(NSString *)networkName {
    AMTapEvent *tapEvent = [AMTapEvent new];
    tapEvent.adType = AMAdTypeInterstitial;
    tapEvent.network = networkName;
    tapEvent.unitId = self.unitId;
    if (self.interstitialLoader.campaign) {
        tapEvent.campaignId = @(self.interstitialLoader.campaign.campaignId);
    }
    [AMAd trackTapEvent:tapEvent completion:nil];
}

#pragma mark - Memory management

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
