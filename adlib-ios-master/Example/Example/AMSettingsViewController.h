//
//  AMSettingsViewController.h
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XLForm/XLForm.h>

@class AMBannerView;

@interface AMSettingsViewController : XLFormViewController
@property (nonatomic, strong) AMBannerView *bannerView;

@end
