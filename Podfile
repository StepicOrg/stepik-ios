# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

def shared_pods
    pod 'Alamofire'
    pod 'SwiftyJSON'
    pod 'SDWebImage'
    pod 'SVGKit', :git => 'https://github.com/SVGKit/SVGKit.git', :branch => '2.x'
end

def all_pods
    shared_pods
    
    pod 'TextFieldEffects'
    pod "DownloadButton"
    pod 'SVProgressHUD'
    
    pod 'TSMessages', :git => 'https://github.com/KrauseFx/TSMessages.git'
    pod 'Fabric'
    pod 'Crashlytics'
    
    pod 'DZNEmptyDataSet'
    pod 'FLKAutoLayout', '0.2.1'
    pod 'YandexMobileMetrica/Dynamic'

    pod 'Firebase', '<= 3.4.0'
#    pod 'Firebase/Messaging'
    pod 'FirebaseAppIndexing', '1.0.4'
    pod 'FirebaseMessaging', '1.1.1'
    pod 'FirebaseAnalytics', '3.3.0'
#    pod 'Firebase/Core'
    
    pod 'Mixpanel-swift'

    pod 'BEMCheckBox'
    pod 'IQKeyboardManagerSwift'
    pod 'Kanna', '~> 2.0.0'
    pod 'CRToast'
    pod 'TUSafariActivity', '~> 1.0'
    
    pod "VK-ios-sdk" 
    pod 'FBSDKCoreKit'
    pod 'FBSDKLoginKit'
    
    
end

target 'Stepic' do
    all_pods
    target 'StepicTests' do
        inherit! :search_paths
        all_pods
    end
end

target 'SberbankUniversity' do 
    all_pods
end

target 'StepicTV' do
    platform :tvos, '9.0'
    shared_pods
    pod "SwiftSoup"
end
