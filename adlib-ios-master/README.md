# Adlib

## Usage

Clone the repo, and run `pod install` in both the root directory and the Example directory.  
Select one of the aggregate targets (Adlib-universal, Adlib-universal-beta or Adlib-universal-staging) and run 'Product > Archive' from XCode's menu.

## Setup

1.  Initialize AdLibManager with your AdLib App ID.
  ```obj-c
  AdlibClient *adlibClient = [AdlibClient sharedClient];
  [adlibClient startWithAppId:@"your-app-id" delegate:self];
  ```

  For each AdLib Ad Unit in your app, add an AMBannerView to your ViewController and initialize it with the appropriate ID.
  ```obj-c
  bannerView.unitId = @"your-ad-unit-id";
  bannerView.rootViewController = self;
  bannerView.delegate = self;
  ```

2. Start loading ads.
  ```obj-c
  [bannerView loadAd];
  ```
## Demographic Parameters

AdLib accepts the following demographic parameters, which you should set when available:

1. [adlibClient setAge: 21];
2. [adlibClient setGender: AMAdQueryGenderFemale];
3. [adlibClient setMaritalStatus: AMAdQueryMaritalStatusSingle];
4. [adlibClient setZip: @"12345"];
5. [adlibClient setIncome: 75000];
6. [adlibClient setLocation: myCLLocation];
7. [adlibClient setCountry: @"Canada"];

You can also request that AdLib capture location updates itself:

```obj-c
[adlibClient updateLocation];
```

## Delegation

Set an AMBannerViewDelegate to receive a callback when an ad loads, is clicked or receives an error.

```obj-c
- (void)bannerView:(AMBannerView *)bannerView didReceiveBannerWithNetwork:(NSString *)networkName;
- (void)bannerViewFailedToLoadBanner:(AMBannerView *)bannerView error:(NSError *)error;
- (void)bannerView:(AMBannerView *)bannerView didTapBannerViewWithNetwork:(NSString *)networkName;
```

## Requirements

XCode 6+, iOS 8+, and [CocoaPods](https://guides.cocoapods.org/using/index.html).

## Installation

Adlib is available as a framework.  To install it,  follow the usage instructions above and drag the Adlib.framework file, located in 'Output/Adlib-Release-iphoneuniversal/', to the "embedded frameworks" section of the project's target.

## Author

Adlib Mediation, support@adlibmediation.com
