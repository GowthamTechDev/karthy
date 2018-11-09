p#
# Be sure to run `pod lib lint Adlib.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Adlib"
  s.version          = "0.1.0"
  s.summary          = ""
  s.description      = <<-DESC
                       DESC
  s.homepage         = "https://github.com/adlib2015/Adlib"
  s.license          = {
     :type => 'Commercial',
     :text => <<-LICENSE
     Copyright (c) Adlib Mediation
     LICENSE
  }
  s.author           = { "Adlib Mediation" => "support@adlib.com" }
  s.source           = { :git => "https://github.com/adlib2015/adlib-ios.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.public_header_files = 'Pod/Classes/**/*.h', 'Vendor/ConversantSDK-4.5.0/*.h', 'Vendor/applovin-ios-sdk-2.5.4/headers/*.h'

  s.resource_bundles = {
    'StartApp' => ['Vendor/StartApp-3.3.2/StartApp.bundle']
  }


  # s.frameworks = 'UIKit', 'CoreLocation', 'WebKit', 'CoreMedia', 'AudioToolbox', 'MessageUI', 'SystemConfiguration', 'CoreGraphics', 'StoreKit', 'AdSupport', 'AVFoundation', 'CoreTelephony', 'MediaPlayer', 'AddressBook', 'AddressBookUI', 'PassKit', 'Twitter'
  s.frameworks = 'CoreLocation', 'AddressBook', 'AddressBookUI', 'PassKit', 'Twitter'
  s.dependency 'AFNetworking'
  s.dependency 'Mantle'
  s.dependency 'InMobiSDK'
  s.dependency 'PWAds'

  # There is a cocoapod bug related to loading pods that are packaged as frameworks.  The current workaround is to load the dependency as a vendored framework: https://github.com/CocoaPods/CocoaPods/issues/1824#issuecomment-65285758
  s.vendored_frameworks = 'Vendor/GoogleMobileAdsSdkiOS-7.7.1/GoogleMobileAds.framework', 'Vendor/StartApp-3.3.2/StartApp.framework'
  # Conversant isn't updating the cocoapods repo.  May need to create a spec repo to point to the correct version.  For now, import it as a static lib.
  s.preserve_paths = 'Vendor/ConversantSDK-4.5.0/libGreystripeSDK.a', 'Vendor/applovin-ios-sdk-3.2.2/libAppLovinSdk.a'
  s.ios.vendored_libraries = 'Vendor/ConversantSDK-4.5.0/libGreystripeSDK.a', 'Vendor/applovin-ios-sdk-3.2.2/libAppLovinSdk.a'
end
