//
//  ALAPIInterstitialViewAdapter.m
//  Adlib
//
//  Copyright (c) 2016 Adlib Mediation. All rights reserved.
//

#import "AMAPIInterstitialViewAdapter.h"
#import "AMAPIInterstitialView.h"
#import "AMAd.h"

@interface AMAPIInterstitialViewAdapter() <AMAPIInterstitialViewDelegate>
@property (nonatomic, strong) AMAPIInterstitialView *apiInterstitialView;

@end

@implementation AMAPIInterstitialViewAdapter
@synthesize provider = _provider;
@synthesize completion = _completion;
@synthesize show = _show;
@synthesize tapped = _tapped;
@synthesize dismissed = _dismissed;
@synthesize forceAPINext = _forceAPINext;
@synthesize rootViewController = _rootViewController;

#pragma mark - Properties

- (AMAPIInterstitialView *)apiInterstitialView {
    if (_apiInterstitialView) {
        return _apiInterstitialView;
    }
    //NSLog(@"Creating Adapter for AdLib");
    _apiInterstitialView = [[AMAPIInterstitialView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _apiInterstitialView.delegate = self;
    return _apiInterstitialView;
}

- (UIView *)interstitialView {
    return self.apiInterstitialView;
}

#pragma mark - ALAdNetworkInterstitialAdapter

- (void)configure:(AMNetworkConfiguration *)networkConfiguration interstitialView:(AMInterstitialView *)interstitialView {
    self.apiInterstitialView.unitId = interstitialView.unitId;
}

- (void)loadInterstitial {
    //NSLog(@"Calling API Load interstitial. Has delegate? : %@ with class %@",((_apiInterstitialView.delegate) ? @"True" : @"False"), NSStringFromClass([_apiInterstitialView class]));
    //NSLog(@"view has frame h:%f w: %f",_apiInterstitialView.frame.size.height,_apiInterstitialView.frame.size.width);
    [self.apiInterstitialView loadInterstitial];
}

- (void)showInterstitial {
    //NSLog(@"Calling API Show interstitial. Has delegate? : %@ with class %@",((_apiInterstitialView.delegate) ? @"True" : @"False"), NSStringFromClass([_apiInterstitialView class]));
    //NSLog(@"view has frame h:%f w: %f",_apiInterstitialView.frame.size.height,_apiInterstitialView.frame.size.width);
    self.apiInterstitialView.rootViewController = self.rootViewController;
    [self.apiInterstitialView showInterstitial];
}

#pragma mark - ALAPIInterstitialViewDelegate

- (void)APIInterstitialViewDidReceiveAd:(AMAPIInterstitialView *)interstitialView {
    self.forceAPINext = interstitialView.ad.force;
   // NSLog(@"API Adapter did recieve ad!");
    if (self.completion) self.completion(YES, self, interstitialView.ad.network);
}

- (void)APIInterstitialViewFailedToReceiveAd:(AMAPIInterstitialView *)interstitialView {
    if (self.completion) self.completion(NO, self, self.provider.name);
}

- (void)APIInterstitialViewDidShowAd:(AMAPIInterstitialView *)interstitialView {
    self.forceAPINext = interstitialView.ad.force;
    
    if (self.show) self.show(YES, self, interstitialView.ad.network);
}

- (void)APIInterstitialViewFailedToShowAd:(AMAPIInterstitialView *)interstitialView {
    if (self.show) self.show(NO, self, self.provider.name);
}

- (void)APIInterstitialViewDidTapInterstitial:(AMAPIInterstitialView *)interstitialView {
    if (self.tapped) self.tapped(self, interstitialView.ad.network);
}

- (void)APIInterstitialViewDidDismissInterstitial:(AMAPIInterstitialView *)interstitialView {
    if (self.dismissed) self.dismissed(self, interstitialView.ad.network);
}

@end
