//
//  ALAPIInterstitialView.m
//  Adlib
//
//  Copyright (c) 2016 Adlib Mediation. All rights reserved.
//

#import "AMAPIInterstitialView.h"
#import "AMAd.h"
#import "AMMacros.h"
#import "AMClientConfiguration.h"
#import "AdlibClient.h"
#import "AMNetworkConfiguration.h"

@interface AMAPIInterstitialView()
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIImage *loadedImage;
@property (nonatomic, weak) NSURL *loadedURL;
@property (nonatomic, weak) UIView *tapOverlayView;
@property (nonatomic, weak) UIWebView *webView;

@end

@implementation AMAPIInterstitialView

float dismissBtnSize = 50.0f;

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

- (void)setup{
   // NSLog(@"Setting up intersitital View API");
   /* UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor clearColor];
    self.imageView = imageView;
    [self addSubview:self.imageView]; */

    UIView *tapOverlayView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    tapOverlayView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [tapOverlayView addGestureRecognizer:tapGestureRecognizer];
    tapOverlayView.userInteractionEnabled = YES;
    [self addSubview:tapOverlayView];
    self.tapOverlayView = tapOverlayView;
    
    self.frame = [[UIScreen mainScreen] bounds];
    self.backgroundColor = [UIColor blueColor];
}

/*- (void)willRemoveSubview:(UIView *)subview
{
    [self viewDismissed:self];
} */

- (void)addInterstitialSubView:(UIView *)interstitialView {
    
    // Remove previous interstitial and add this interstitial view as a subview.
    if (self.imageView.superview) {
        [self.imageView removeFromSuperview];
    }
    
    if (interstitialView) {
        [self addSubview:self.imageView];
    }
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
            
            CGRectIntegral([[UIScreen mainScreen] bounds]);
        });
    }
    
    self.tapOverlayView.frame = self.bounds;
}

#pragma mark - Actions

- (void)viewTapped:(id)sender {
    if (self.ad) {
        [[UIApplication sharedApplication] openURL:self.ad.clickURL];
        
        if (self.delegate) {
            [self.delegate APIInterstitialViewDidTapInterstitial:self];
            
            if(self.imageView)
            {
                [self.imageView removeFromSuperview];
            }
            if(self.webView)
            {
                [self.webView removeFromSuperview];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                self.window.windowLevel = UIWindowLevelNormal;
                [self removeFromSuperview];
            });
        }
    }
}

- (void)viewDismissed:(id)sender {
    if (self.ad) {
        if (self.delegate) {
            if(self.imageView)
            {
                [self.imageView removeFromSuperview];
            }
            if(self.webView)
            {
                [self.webView removeFromSuperview];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.window.windowLevel = UIWindowLevelNormal;
                [self removeFromSuperview];
            });
            
            [self.delegate APIInterstitialViewDidDismissInterstitial:self];
        }
    }
}


-(void)addImageToInterstitial:(UIImage*)image
{
   // NSLog(@"Trying To add image view");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIImageView *adView = [[UIImageView alloc] initWithImage:image];
        adView.frame = CGRectMake((self.rootViewController.view.frame.size.width / 2) - (adView.frame.size.width / 2), (self.rootViewController.view.frame.size.height / 2) - (adView.frame.size.height / 2), adView.frame.size.width, adView.frame.size.height);
        adView.contentMode = UIViewContentModeScaleAspectFit;
        adView.backgroundColor = [UIColor blackColor];
        self.imageView = adView;
        
        UIButton *dismissBtn = [[UIButton alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - dismissBtnSize, 0.0f , dismissBtnSize, dismissBtnSize)];
       // dismissBtn.alpha = 0.5f;
        dismissBtn.layer.cornerRadius = dismissBtnSize / 2;
        dismissBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
        dismissBtn.layer.borderWidth = 2.0f;
        [dismissBtn setTitle:@"X" forState:UIControlStateNormal];
        
        [dismissBtn addTarget:self action:@selector(viewDismissed:) forControlEvents:UIControlEventTouchDown];
        dismissBtn.backgroundColor = [UIColor grayColor];
        
        [self addSubview:self.imageView];
        [self addSubview:dismissBtn];
       // NSLog(@"DID add image view");
    });
}


-(void)addWebViewToInterstitial:(NSURL *)url
{
   // NSLog(@"Trying To add web view");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWebView *webView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        webView.backgroundColor = [UIColor blackColor];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        [webView loadRequest:urlRequest];
        self.webView = webView;
        
        UIButton *dismissBtn = [[UIButton alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - dismissBtnSize, 0.0f , dismissBtnSize, dismissBtnSize)];
        //dismissBtn.alpha = 0.5f;
        dismissBtn.layer.cornerRadius = dismissBtnSize / 2;
        dismissBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
        dismissBtn.layer.borderWidth = 2.0f;
        [dismissBtn setTitle:@"X" forState:UIControlStateNormal];
        
        [dismissBtn addTarget:self action:@selector(viewDismissed:) forControlEvents:UIControlEventTouchDown];
        dismissBtn.backgroundColor = [UIColor grayColor];
        
        [self addSubview:self.webView];
        [self addSubview:dismissBtn];
      //  NSLog(@"Did add webview!!!");
    });
}


- (void)loadInterstitial {
    self.loadedImage = nil;
    self.loadedURL = nil;
    AMWeakSelf weakSelf = self;
    AMDemographics *demographics = [AdlibClient sharedClient].demographics;
    NSString *appId = [AdlibClient sharedClient].appId;
    [AMAd loadAdWithAppId:appId adType:2 unitId:self.unitId campaignId:0 demographics:demographics completion:^(AMAd *ad) {
        if (ad) {
            NSLog(@"API Load Interstitial with ad!");
            [weakSelf loadInterstitialWithAd:ad];
        } else if (weakSelf.delegate) {
            [weakSelf.delegate APIInterstitialViewFailedToReceiveAd:weakSelf];
        }
    }];
}

- (void)loadInterstitialWithAd:(AMAd *)ad {
    self.loadedImage = nil;
    self.loadedURL = nil;
    self.ad = ad;
    AMWeakSelf weakSelf = self;
    if (ad) {
        NSURLSessionDataTask *downloadImageTask = [[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:ad.adURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error){
                // NSLog(@"failed to load - error downloading");
                [self.delegate APIInterstitialViewFailedToReceiveAd:self];
                return;
            }
            if (response) {
                if([ad.network isEqualToString:@"mMedia"]) {
                    [weakSelf addWebViewToInterstitial:ad.adURL];
                    weakSelf.loadedURL = ad.adURL;
                   // NSLog(@"Got Web address from API Call. Delegate : %@", weakSelf.delegate);
                } else {
                    UIImage *image = [[UIImage alloc] initWithData:data];
                    weakSelf.loadedImage = image;
                   // NSLog(@"Got Image from API Call. Delegate : %@", weakSelf.delegate);
                    [weakSelf addImageToInterstitial:image];
                }
                
                [weakSelf.delegate APIInterstitialViewDidReceiveAd:weakSelf];
            }
            else
            {
                 //NSLog(@"failed to load when downloaded");
                [self.delegate APIInterstitialViewFailedToReceiveAd:self];
                return;
            }
        }];
        [downloadImageTask resume];
        
        [self setNeedsLayout];
        [self layoutIfNeeded];

    } else if (self.delegate) {
        //NSLog(@"failed to load - no ad");
        [self.delegate APIInterstitialViewFailedToReceiveAd:self];
    }
}

- (void)showInterstitial{
    AMWeakSelf weakSelf = self;
    //NSLog(@"API Call show interstitial. Image: %@ or URL %@", weakSelf.loadedImage, weakSelf.loadedURL);
    if((weakSelf.loadedImage !=  nil) || (weakSelf.loadedURL != nil))
    {
       // NSLog(@"Image/URL Loaded. Loading on %@", NSStringFromClass([weakSelf.rootViewController class]));

        dispatch_async(dispatch_get_main_queue(), ^{
            self.frame = [[UIScreen mainScreen] bounds];
            [[[UIApplication sharedApplication] keyWindow] addSubview:self];
            self.window.windowLevel = UIWindowLevelStatusBar + 1;
           // [self.rootViewController.view addSubview:self];
        });
        [self.delegate APIInterstitialViewDidShowAd:self];
    }
    else
    {
       // NSLog(@"No Image/URL Loaded");
        [self.delegate APIInterstitialViewFailedToShowAd:self];
    }
}

@end
