//
//  ALAPIBannerView.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMAPIBannerView.h"
#import "AMAd.h"
#import "AMMacros.h"
#import "AMClientConfiguration.h"
#import "AdlibClient.h"
#import "AMNetworkConfiguration.h"

@interface AMAPIBannerView()
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIView *tapOverlayView;

@end

@implementation AMAPIBannerView

#pragma mark - Initialization

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor clearColor];
    [self addSubview:imageView];
    self.imageView = imageView;
    
    UIView *tapOverlayView = [[UIView alloc] initWithFrame:self.bounds];
    tapOverlayView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [tapOverlayView addGestureRecognizer:tapGestureRecognizer];
    tapOverlayView.userInteractionEnabled = YES;
    [self addSubview:tapOverlayView];
    self.tapOverlayView = tapOverlayView;
    
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.ad) {
        self.imageView.frame = ({
            CGRect frame = self.imageView.frame;
            
            frame.size.width = self.ad.width ? self.ad.width.floatValue : self.bounds.size.width;
            frame.size.height = self.ad.height ? self.ad.height.floatValue : self.bounds.size.height;
            frame.origin.x = (CGRectGetWidth(self.bounds) - CGRectGetWidth(frame)) / 2.0;
            frame.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(frame)) / 2.0;
            
            CGRectIntegral(frame);
        });
    }
    
    self.tapOverlayView.frame = self.bounds;
}

#pragma mark - Actions

- (void)viewTapped:(id)sender {
    if (self.ad) {
        [[UIApplication sharedApplication] openURL:self.ad.clickURL];
        
        if (self.delegate) {
            [self.delegate APIBannerViewDidTapBanner:self];
        }
    }
}

- (void)loadBanner {
    AMWeakSelf weakSelf = self;
    AMDemographics *demographics = [AdlibClient sharedClient].demographics;
    NSString *appId = [AdlibClient sharedClient].appId;
    [AMAd loadAdWithAppId:appId adType:0 unitId:self.unitId campaignId:0 demographics:demographics completion:^(AMAd *ad) {
        if (ad) {
            [weakSelf loadBannerWithAd:ad];
        } else if (weakSelf.delegate) {
            [weakSelf.delegate APIBannerViewFailedToReceiveAd:weakSelf];
        }
    }];
}

- (void)loadBannerWithAd:(AMAd *)ad {
    self.ad = ad;
    if (ad) {
        AMWeakSelf weakSelf = self;
        NSURLSessionDataTask *downloadImageTask = [[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:ad.adURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) return;
            
            if (response) {
                UIImage *image = [[UIImage alloc] initWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.imageView.image = image;
                    });
                }
            }
        }];
        [downloadImageTask resume];
        
        if (self.delegate) {
            [self.delegate APIBannerViewDidReceiveAd:self];
        }
        
        [self setNeedsLayout];
        [self layoutIfNeeded];
    } else if (self.delegate) {
        [self.delegate APIBannerViewFailedToReceiveAd:self];
    }
}

@end
