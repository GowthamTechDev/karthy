//
//  ALDemoViewController.m
//  Adlib
//
//  Copyright (c) 2015 Adlib Mediation. All rights reserved.
//

#import "AMDemoViewController.h"
#import "AMSettingsViewController.h"
#import <Adlib/Adlib.h>

@interface AMDemoViewController () <AMBannerViewDelegate, AMInterstitialViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet AMBannerView *bannerView;
@property (strong, nonatomic) IBOutlet AMInterstitialView *interstitialView;

@end

@implementation AMDemoViewController

#pragma mark - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURLRequest *URLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://en.wikipedia.org/wiki/Main_Page"]];
    
    [self.webView loadRequest:URLRequest];
    
   // self.bannerView.rootViewController = self;
   // self.bannerView.delegate = self;
    
    self.interstitialView = [[AMInterstitialView alloc] init];
    self.interstitialView.rootViewController = self;
    self.interstitialView.delegate = self;
    
    // Network configuration hasn't been loaded from the API yet, wait until it has to configure unitId.
    AdlibClient *client = [AdlibClient sharedClient];
    if (!client.started) {
        __block __weak id startedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AdlibClientStartedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            if (client.currentUnitIds && client.currentUnitIds.count > 0) {
               // self.bannerView.unitId = client.currentUnitIds[0];
               // [self.bannerView setUnitId:@"100023"];
                [self.interstitialView setUnitId:@"100025"];
            }
            //[self.bannerView loadAd];
            [self.interstitialView loadAd];
            [[NSNotificationCenter defaultCenter] removeObserver:startedObserver name:nil object:nil];
        }];
    } else {
        //[self.bannerView loadAd];
        [self.interstitialView loadAd];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - ALBannerViewDelegate

- (void)bannerView:(AMBannerView *)bannerView didReceiveBannerWithNetwork:(NSString *)networkName {
    NSLog(@"Loaded banner with network: %@", networkName);
}

- (void)bannerViewFailedToLoadBanner:(AMBannerView *)bannerView error:(NSError *)error {
    NSLog(@"Failed to load banner: %@", error);
}

- (void)bannerView:(AMBannerView *)bannerView didTapBannerViewWithNetwork:(NSString *)networkName {
    NSLog(@"Tapped banner with network: %@", networkName);
}


- (void)interstitialView:(AMInterstitialView *)interstitialView didReceiveInterstitialWithNetwork:(NSString *)networkName {
    NSLog(@"Loaded interstitial with network: %@", networkName);
    [self.interstitialView showAd];
}

- (void)interstitialView:(AMInterstitialView *)interstitialView didShowInterstitialWithNetwork:(NSString *)networkName
{
    NSLog(@"Showing interstitial with network: %@", networkName);
}

-(void)interstitialViewFailedToShowInterstitial:(AMInterstitialView *)interstitialView error:(NSError *)error
{
    NSLog(@"Failed to show interstitial: %@", error);
    [self.interstitialView loadAd];
}

- (void)interstitialViewFailedToLoadBanner:(AMInterstitialView *)interstitialView error:(NSError *)error {
    NSLog(@"Failed to load interstitial: %@", error);
}

- (void)interstitialView:(AMInterstitialView *)interstitialView didTapInterstitialViewWithNetwork:(NSString *)networkName {
    NSLog(@"Tapped interstitial with network: %@", networkName);
    [self.interstitialView loadAd];
}

-(void)interstitialView:(AMInterstitialView *)interstitialView didDismissInterstitialViewWithNetwork:(NSString *)networkName
{
    NSLog(@"Dismissed interstitial with network: %@", networkName);
    [self.interstitialView loadAd];
}


#pragma mark - Navigation
/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AMDemoSettingsSegue"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        AMSettingsViewController *settingsViewController = (AMSettingsViewController *)navigationController.topViewController;
        [self.bannerView stopRefreshing];
        settingsViewController.bannerView = self.bannerView;
    }
}
*/
@end
