//
//  ALInterstitialView.h
//  Adlib
//
//
//  Copyright (c) 2016 AdLib Mediation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMInterstitialViewDelegate.h"

@class AMInterstitialView;

extern NSString *const AMInterstitialViewErrorDomain;
extern const NSInteger AMInterstitialViewErrorLoadFailed;
extern const NSInteger AMInterstitialViewErrorShowFailed;

/**
 *  `AMInterstitialView` renders interstitial ads from the various
 */
@interface AMInterstitialView : UIView
@property (nonatomic, weak) id<AMInterstitialViewDelegate> delegate;
@property (nonatomic, copy) NSString *unitId;
@property (nonatomic, strong) UIViewController *rootViewController;
@property (nonatomic, readonly) NSArray *availableNetworks;

- (void)loadAd;
- (void)showAd;
- (void)removeAd;

@end
