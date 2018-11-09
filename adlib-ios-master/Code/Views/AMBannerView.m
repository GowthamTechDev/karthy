//
//  ALBannerView.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMBannerView.h"
#import "AMMacros.h"
#import "AMProvider.h"
#import "AMProviderBannerAdapter.h"
#import "AMAPIBannerViewAdapter.h"
#import "AMAdMobBannerAdapter.h"
#import "AMInMobiBannerAdapter.h"
#import "AMGreystripeBannerAdapter.h"
#import "AMAppLovinBannerAdapter.h"
#import "AMAPIBannerView.h"
#import "AMRegisterEvent.h"
#import "AMTapEvent.h"
#import "AdlibClient.h"
#import "AMNetworkConfiguration.h"
#import "AMNetworkConfigurationManager.h"
#import "AMAdUnit.h"
#import "AMBannerLoader.h"
#import "AMCampaign.h"

NSString *const AMBannerViewErrorDomain = @"com.adlib.error.banner.load";
const NSInteger AMBannerViewErrorLoadFailed = 1;

@interface AMBannerView()
@property (nonatomic, weak) UIView *adView;
@property (nonatomic, readwrite, assign) NSTimeInterval refreshTime;
@property (nonatomic, strong) NSTimer *refreshTimer;
@property (nonatomic, assign) BOOL bannersConfigured;
@property (nonatomic, assign) BOOL adRequested;
@property (nonatomic, assign) BOOL adLoaded;
@property (nonatomic, assign) BOOL forceAPINext;
@property (nonatomic, assign) NSUInteger failCount;
@property (nonatomic, strong) AMBannerLoader *bannerLoader;
@property (nonatomic, strong) AdlibClient *client;
@property (nonatomic, strong) AMAdUnit *adUnit;
@property (nonatomic, strong) NSSet *availableAdapters;

@end

@implementation AMBannerView

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
    self.bannerLoader = [[AMBannerLoader alloc] initWithAdlibClient:self.client];
    self.bannerLoader.size = self.bounds.size;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopRefreshing) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeRefresh) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)configure {
    self.bannersConfigured = NO;
    
    if (!self.client.started) {
        // Network configuration hasn't been loaded from the API yet, wait until it has to configure the banner providers.
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
           NSLocalizedDescriptionKey: @"Error loading banner, missing adUnit.  Check that the ad unit id is correct."
        };
        NSError *error = [NSError errorWithDomain:AMBannerViewErrorDomain code:AMBannerViewErrorLoadFailed userInfo:userInfo];
        if (self.delegate && [self.delegate respondsToSelector:@selector(bannerViewFailedToLoadBanner:error:)]) {
            [self.delegate bannerViewFailedToLoadBanner:self error:error];
        }
        return;
    }
    
    if (self.adUnit.refreshTime) {
        self.refreshTime = [self.adUnit.refreshTime doubleValue];
    }
    
    NSMutableSet *availableAdapters = [NSMutableSet new];
    for (AMProvider *provider in self.client.availableProviders) {
        NSObject<AMProviderBannerAdapter> *adapter = [provider bannerAdapterWithProvider];
        
        // Configure
        [adapter configure:[AMNetworkConfigurationManager sharedManager].networkConfiguration bannerView:self];
        
        // Add tap callback
        AMWeakSelf weakSelf = self;
        adapter.tapped = ^(id<AMProviderBannerAdapter> bannerViewAdapter, NSString *networkName) {
            [weakSelf trackTapEvent:networkName];
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(bannerView:didTapBannerViewWithNetwork:)]) {
                [weakSelf.delegate bannerView:weakSelf didTapBannerViewWithNetwork:networkName];
            }
            NSObject<AdlibClientDelegate> *clientDelegate = weakSelf.client.delegate;
            if (clientDelegate && [clientDelegate respondsToSelector:@selector(adlibClient:didTapBannerWithNetwork:)]) {
                [clientDelegate adlibClient:weakSelf.delegate didTapBannerWithNetwork:networkName];
            }
        };
        
        [availableAdapters addObject:adapter];
    }
    self.availableAdapters = availableAdapters;
    
    self.bannersConfigured = YES;
    
    if (self.adRequested) {
        // Ad was requested before the banner was configured, load the ad.
        [self loadAd];
    }
}

- (void)addBannerSubView:(UIView *)bannerView {
    self.adLoaded = YES;
    
    // Remove previous banner and add this banner view as a subview.
    if (self.adView.superview) {
        [self.adView removeFromSuperview];
    }
    
    if (bannerView) {
        [self addSubview:bannerView];
        self.adView = bannerView;
    }
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.adView) {
        self.adView.frame = ({
            CGRect frame = self.adView.frame;
            
            frame.origin.x = (CGRectGetWidth(self.bounds) - CGRectGetWidth(frame)) / 2.0;
            frame.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(frame)) / 2.0;
            
            CGRectIntegral(frame);
        });
    }
    
    self.bannerLoader.size = self.bounds.size;
}

#pragma mark - Actions

- (void)loadAd {
    if (!self.bannersConfigured) {
        self.adRequested = YES;
        return;
    }

    NSMutableSet *currentAdapters = [NSMutableSet new];
    for (AMProvider *provider in self.client.currentProviders) {
        NSSet *matchingAdapter = [self.availableAdapters filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSObject<AMProviderBannerAdapter> *adapter, NSDictionary *bindings) {
            return provider.type == adapter.provider.type;
        }]];
        [currentAdapters unionSet:matchingAdapter];
    }
    AMWeakSelf weakSelf = self;
    [self.bannerLoader loadBannerWithProviders:currentAdapters adUnit:self.adUnit success:^(UIView *view, NSString *networkName) {
        [weakSelf addBannerSubView:view];
        
        // Delegate calls
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(bannerView:didReceiveBannerWithNetwork:)]) {
            [weakSelf.delegate bannerView:weakSelf didReceiveBannerWithNetwork:networkName];
        }
        NSObject<AdlibClientDelegate> *clientDelegate = weakSelf.client.delegate;
        if (clientDelegate && [clientDelegate respondsToSelector:@selector(adlibClient:didReceiveBannerWithNetwork:)]) {
            [clientDelegate adlibClient:weakSelf.client didReceiveBannerWithNetwork:networkName];
        }
        
        // Refresh ad if refresh time is greater than 0.
        weakSelf.refreshTimer = (weakSelf.refreshTime > 0) ? [NSTimer scheduledTimerWithTimeInterval:weakSelf.refreshTime target:weakSelf selector:@selector(loadAd) userInfo:nil repeats:NO] : nil;
    } failure:^{
        if ([weakSelf.delegate respondsToSelector:@selector(bannerViewFailedToLoadBanner:error:)]) {
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: @"Banner failed to load."
            };
            NSError *error = [NSError errorWithDomain:AMBannerViewErrorDomain code:AMBannerViewErrorLoadFailed userInfo:userInfo];
            [weakSelf.delegate bannerViewFailedToLoadBanner:weakSelf error:error];
        }
    }];
}

- (void)handleRefresh:(NSTimer *)timer {
    [self loadAd];
}

- (void)stopRefreshing {
    if (self.refreshTimer) {
        [self.refreshTimer invalidate];
        self.refreshTimer = nil;
    }
}

- (void)removeAd {
    [self stopRefreshing];
    self.adLoaded = NO;
    if (self.adView.superview) {
        [self.adView removeFromSuperview];
    }
}

#pragma mark - Events

- (void)trackTapEvent:(NSString *)networkName {
    AMTapEvent *tapEvent = [AMTapEvent new];
    tapEvent.adType = AMAdTypeBanner;
    tapEvent.network = networkName;
    tapEvent.unitId = self.unitId;
    if (self.bannerLoader.campaign) {
        tapEvent.campaignId = @(self.bannerLoader.campaign.campaignId);
    }
    [AMAd trackTapEvent:tapEvent completion:nil];
}

#pragma mark - Application state

- (void)resumeRefresh {
    if (self.refreshTime > 0) {
        [self loadAd];
    }
}

#pragma mark - Memory management

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
