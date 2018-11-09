//
//  ALBannerView.h
//  Adlib
//
//  Created by Peter Grates on 4/4/15.
//  Copyright (c) 2015 adlib. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMBannerViewDelegate.h"

@class AMBannerView;

extern NSString *const AMBannerViewErrorDomain;
extern const NSInteger AMBannerViewErrorLoadFailed;

/**
 *  `AMBannerView` renders banner ads from the various
 */
@interface AMBannerView : UIView
@property (nonatomic, weak) id<AMBannerViewDelegate> delegate;
@property (nonatomic, copy) NSString *unitId;
@property (nonatomic, strong) UIViewController *rootViewController;
@property (nonatomic, readonly) NSTimeInterval refreshTime;
@property (nonatomic, readonly) NSArray *availableNetworks;

- (void)loadAd;
- (void)stopRefreshing;
- (void)removeAd;

@end
