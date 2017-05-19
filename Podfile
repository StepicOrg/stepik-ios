# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

def all_pods
    pod 'Alamofire', '~> 4.4'
    pod 'SwiftyJSON', '3.1.4'
    pod 'SDWebImage'
    pod 'TextFieldEffects'
    pod "DownloadButton"
    pod 'SVProgressHUD'
    pod 'FLKAutoLayout', '0.2.1'
    pod 'TSMessages', :git => 'https://github.com/KrauseFx/TSMessages.git'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'DZNEmptyDataSet'
    
    pod 'YandexMobileMetrica/Dynamic'

    pod 'Firebase/Core', '3.16.0'
    pod 'Firebase/AppIndexing', '3.16.0'
    pod 'Firebase/Messaging', '3.16.0'
    pod 'Firebase/Analytics', '3.16.0'
    
    pod 'Mixpanel-swift'
    
    pod "MagicalRecord"
    pod 'BEMCheckBox'
    pod 'IQKeyboardManagerSwift'
    pod 'Kanna', '~> 2.0.0'
    pod 'CRToast', :git => 'https://github.com/cruffenach/CRToast.git', :branch => 'master'
    pod 'TUSafariActivity', '~> 1.0'
    
    pod "VK-ios-sdk"
    pod 'FBSDKCoreKit'
    pod 'FBSDKLoginKit'
    
    pod 'SVGKit', :git => 'https://github.com/SVGKit/SVGKit.git', :branch => '2.x'
    
    pod 'Presentr'
    
    pod 'Agrume', :git => 'https://github.com/Ostrenkiy/Agrume.git', :branch => 'feature/single-horizontal-dismiss'
end

def testing_pods
    pod 'Quick'
    pod 'Nimble'
end

target 'Stepic' do
    all_pods
    target 'StepicTests' do
        inherit! :search_paths
        all_pods
        testing_pods
    end
end

target 'SberbankUniversity' do 
    all_pods
end

target 'Adaptive PDD' do
    all_pods
    
    pod 'Koloda', '4.0'
end
