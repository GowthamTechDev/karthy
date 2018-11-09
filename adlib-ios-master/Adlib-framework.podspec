#
# Be sure to run `pod lib lint Adlib-framework.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Adlib-framework"
  s.version          = "1.0.0"
  s.summary          = "Adlib frameworks"
  s.description      = 'Adlib Mediation'
  s.homepage         = "https://adlibmediation.com"
  s.license          = {
     :type => 'Commercial',
     :text => 'Copyright (c) Adlib Mediation'
  }
  s.author           = { "Adlib Mediation" => "support@adlib.com" }
  s.source           = { :git => "https://github.com/adlib2015/adlib-ios.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.public_header_files = 'Vendor/ConversantSDK-4.5.0/*.h', 'Vendor/applovin-ios-sdk-3.2.2/headers/*.h'
  s.public_header_files = 'Vendor/ConversantSDK-4.5.0/*.h', 'Vendor/applovin-ios-sdk-3.2.2/headers/*.h'

  # s.resource_bundles = {
  #   'StartApp' => ['Vendor/StartApp-2.4.2/StartApp.bundle']
  # }

  s.frameworks = 'CoreLocation', 'AddressBook', 'AddressBookUI', 'PassKit', 'Twitter'
  # s.dependency 'AFNetworking/NSURLSession'
  # s.dependency 'Mantle'
  s.dependency 'InMobiSDK'
  s.dependency 'PWAds'

  s.vendored_frameworks = 'Vendor/GoogleMobileAdsSdkiOS-7.7.1/GoogleMobileAds.framework', 'Vendor/StartApp-3.3.2/StartApp.framework'
  s.preserve_paths = 'Vendor/ConversantSDK-4.5.0/libGreystripeSDK.a', 'Vendor/applovin-ios-sdk-3.2.2/libAppLovinSdk.a'
  s.ios.vendored_libraries = 'Vendor/ConversantSDK-4.5.0/libGreystripeSDK.a', 'Vendor/applovin-ios-sdk-3.2.2/libAppLovinSdk.a'
end
