# Uncomment this line to define a global platform for your project
install! 'cocoapods', :deterministic_uuids => false
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

def all_pods
    pod 'Alamofire', '~> 4.4'
    pod 'SwiftyJSON', '3.1.4'
    pod 'SDWebImage'
    pod 'TextFieldEffects'
    pod "DownloadButton"
    pod 'SVProgressHUD'
    pod 'FLKAutoLayout'
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
    pod 'Highlightr'
    pod "RFKeyboardToolbar", "~> 1.3"
end

def testing_pods
    pod 'Quick'
    pod 'Nimble'
end

def adaptive_pods
    pod 'Koloda', '4.0'
    pod 'SDWebImage/GIF'
    pod 'Charts', '3.0.2'
    pod 'NotificationBannerSwift', '1.4.1' 
end

target 'Stepic' do
    platform :ios, '9.0'
    all_pods
    target 'StepicTests' do
        inherit! :search_paths
        all_pods
        testing_pods
    end
end

target 'SberbankUniversity' do 
    platform :ios, '9.0'
    all_pods
end

target 'Adaptive 1838' do
    platform :ios, '9.0'
    all_pods
    adaptive_pods    
end

target 'Adaptive 1906' do
    platform :ios, '9.0'
    all_pods
    adaptive_pods
end

target 'Adaptive 3067' do
    platform :ios, '9.0'
    all_pods
    adaptive_pods
end

target 'Adaptive 3150' do
    platform :ios, '9.0'
    all_pods
    adaptive_pods
end

target 'Adaptive 3149' do
    platform :ios, '9.0'
    all_pods
    adaptive_pods
end

target 'Adaptive 3124' do
    platform :ios, '9.0'
    all_pods
    adaptive_pods
end

target 'Adaptive 1838 Screenshots' do
    pod 'SimulatorStatusMagic', :configurations => ['Debug']
end

target 'Adaptive 1906 Screenshots' do
    pod 'SimulatorStatusMagic', :configurations => ['Debug']
end

target 'Adaptive 3067 Screenshots' do
    pod 'SimulatorStatusMagic', :configurations => ['Debug']
end

target 'Adaptive 3124 Screenshots' do
    pod 'SimulatorStatusMagic', :configurations => ['Debug']
end

target 'Adaptive 3149 Screenshots' do
    pod 'SimulatorStatusMagic', :configurations => ['Debug']
end

target 'Adaptive 3150 Screenshots' do
    pod 'SimulatorStatusMagic', :configurations => ['Debug']
end

