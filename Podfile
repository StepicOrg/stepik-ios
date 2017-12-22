# Uncomment this line to define a global platform for your project
install! 'cocoapods', :deterministic_uuids => false
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

def shared_pods
    pod 'Alamofire', '~> 4.4'
    pod 'SwiftyJSON', '3.1.4'
    pod 'SDWebImage'
    pod 'SVGKit', :git => 'https://github.com/SVGKit/SVGKit.git', :branch => '2.x'
    pod 'Fabric'
    pod 'Crashlytics', '~> 3.9'
end

def all_pods

    shared_pods
    pod "DownloadButton"
    pod 'SVProgressHUD'
    pod 'FLKAutoLayout', '1.0.1'
    pod 'TSMessages', :git => 'https://github.com/KrauseFx/TSMessages.git'
    pod 'DZNEmptyDataSet'
    pod 'YandexMobileMetrica/Dynamic'
    
    pod 'Firebase/Core'
    pod 'Firebase/AppIndexing'
    pod 'Firebase/Messaging'
    pod 'Firebase/Analytics'
    pod 'Firebase/RemoteConfig'
    
    pod 'Mixpanel-swift', '2.2.3'

    pod 'BEMCheckBox'
    pod 'IQKeyboardManagerSwift'
    pod 'Kanna', '~> 2.0.0'
    pod 'CRToast', :git => 'https://github.com/cruffenach/CRToast.git', :branch => 'master'
    pod 'TUSafariActivity', '~> 1.0'
    
    pod "VK-ios-sdk"
    pod 'FBSDKCoreKit'
    pod 'FBSDKLoginKit'
    
    pod 'Presentr', '1.2.3'
    
    pod 'Agrume', :git => 'https://github.com/Ostrenkiy/Agrume.git', :branch => 'feature/single-horizontal-dismiss'
    pod 'Highlightr'
    pod "RFKeyboardToolbar", "~> 1.3"
    pod 'TTTAttributedLabel'
    pod 'PromiseKit', '~> 4.4'
    pod 'Atributika', '~> 3.0' # update after migration to Swift 4
    pod 'DeviceKit', '~> 1.0'
    pod 'lottie-ios'
    pod 'Koloda', '4.3.1'
    pod 'SDWebImage/GIF'
end

def testing_pods
    pod 'Quick'
    pod 'Nimble'
end

def adaptive_pods
    pod 'Koloda', '4.3.1'
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

target 'StepikTV' do
    platform :tvos, '10.1'
    shared_pods
    target 'StepikTVTests' do
        inherit! :search_paths
        shared_pods
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

