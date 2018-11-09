//
//  AMGreystripeInterstitialViewAdapter.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMGreystripeInterstitialAdapter.h"
#import "AdlibClient.h"
#import "AMNetworkConfiguration.h"
#import <GSFullscreenAd.h>
#import <GSAdDelegate.h>


@interface AMGreystripeInterstitialAdapter() <GSAdDelegate>
@property (nonatomic, strong) GSFullscreenAd *greyStripeInterstitialView;
@end

@implementation AMGreystripeInterstitialAdapter
@synthesize provider = _provder;
@synthesize completion = _completion;
@synthesize show = _show;
@synthesize tapped = _tapped;
@synthesize dismissed = _dismissed;
@synthesize forceAPINext = _forceAPINext;
@synthesize rootViewController = _rootViewController;

#pragma mark - Properties

- (GSFullscreenAd *)greyStripeInterstitialView {
    if (_greyStripeInterstitialView) {
        return _greyStripeInterstitialView;
    }
    _greyStripeInterstitialView = [[GSFullscreenAd alloc] initWithDelegate:self];
    return _greyStripeInterstitialView;
}

- (NSObject *)interstitialView {
    return self.greyStripeInterstitialView;
}

#pragma mark - AMProviderInterstitialAdapter

- (void)configure:(AMNetworkConfiguration *)networkConfiguration interstitialView:(AMInterstitialView *)interstitialView {
    self.rootViewController = interstitialView.rootViewController;
    self.greyStripeInterstitialView = [[GSFullscreenAd alloc] initWithDelegate:self];
}

- (void)loadInterstitial {
    [self.greyStripeInterstitialView fetch];
}

- (void)showInterstitial {
    [self.greyStripeInterstitialView displayFromViewController:self.rootViewController];
}

#pragma mark - GSAdDelegate

- (void)greystripeAdFetchSucceeded:(id<GSAd>)a_ad {
    if (self.completion) self.completion(YES, self, self.provider.name);
}

- (void)greystripeAdFetchFailed:(id<GSAd>)a_ad withError:(GSAdError)a_error {
    if (self.completion) self.completion(NO, self, self.provider.name);
}

-(void)greystripeWillPresentModalViewController {
    if (self.show) self.show(YES, self, self.provider.name);
}

- (void)greystripeAdClickedThrough:(id<GSAd>)a_ad {
    if (self.tapped) self.tapped(self, self.provider.name);
}

-(void)greystripeDidDismissModalViewController{
    if (self.dismissed) self.dismissed(self, self.provider.name);
}

- (UIViewController *)greystripeInterstitialDisplayViewController {
    return self.rootViewController;
}

@end
