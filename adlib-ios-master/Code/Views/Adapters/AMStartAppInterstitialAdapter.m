//
//  AMStartAppInterstitialViewAdapter.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMStartAppInterstitialAdapter.h"
#import "AMNetworkConfiguration.h"
#import "AdlibClient.h"
#import "AMClientConfiguration.h"
#import <StartApp/StartApp.h>

@interface AMStartAppInterstitialAdapter() <STADelegateProtocol>
@property (nonatomic, strong) STAStartAppAd *startAppInterstitialView;

@end

@implementation AMStartAppInterstitialAdapter
@synthesize provider = _provider;
@synthesize completion = _completion;
@synthesize show = _show;
@synthesize tapped = _tapped;
@synthesize dismissed = _dismissed;
@synthesize forceAPINext = _forceAPINext;
@synthesize rootViewController = _rootViewController;

#pragma mark - Properties

- (NSObject *)interstitialView {
    return self.startAppInterstitialView;
}

#pragma mark - ALAdNetworkInterstitialAdapter

- (void)configure:(AMNetworkConfiguration *)networkConfiguration interstitialView:(AMInterstitialView *)interstitialView {
    self.startAppInterstitialView = [[STAStartAppAd alloc] init];
}

- (void)loadInterstitial {
    [self.startAppInterstitialView loadAd];
}

-(void)showInterstitial {
    [self.startAppInterstitialView showAd];
}

#pragma mark - STADelegateProtocol


- (void) didLoadAd:(STAAbstractAd*)ad{
    if (self.completion) self.completion(YES, self, self.provider.name);
}

- (void) failedLoadAd:(STAAbstractAd*)ad withError:(NSError *)error{
    if (self.completion) self.completion(NO, self, self.provider.name);
}

- (void) didShowAd:(STAAbstractAd*)ad{
    if (self.show) self.show(YES, self, self.provider.name);
}

- (void) failedShowAd:(STAAbstractAd*)ad withError:(NSError *)error{
    if (self.show) self.show(NO, self, self.provider.name);
}

- (void) didCloseAd:(STAAbstractAd*)ad{
    if (self.dismissed) self.dismissed(self, self.provider.name);
}

- (void) didClickAd:(STAAbstractAd*)ad{
    if (self.tapped) self.tapped(self, self.provider.name);
}

@end
