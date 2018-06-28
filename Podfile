# Uncomment this line to define a global platform for your project
install! 'cocoapods', :deterministic_uuids => false
source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

def shared_pods
    pod 'Alamofire', '~> 4.4'
    pod 'Atributika', '~> 4.0'
    pod 'SwiftyJSON', '3.1.4'
    pod 'SDWebImage'
    pod 'SVGKit', :git => 'https://github.com/SVGKit/SVGKit.git', :branch => '2.x'
    pod 'Fabric'
    pod 'Crashlytics', '~> 3.9'
    pod 'DeviceKit', '~> 1.0'
    pod 'PromiseKit', '~> 4.4'
end

def all_pods

    shared_pods
    pod "DownloadButton"
    pod 'SVProgressHUD'
    pod 'TSMessages', :git => 'https://github.com/KrauseFx/TSMessages.git'
    pod 'YandexMobileMetrica/Dynamic', '~> 3.0.0'

    pod 'SnapKit', '~> 4.0.0'
    
    pod 'FirebaseCore', '5.0.0'
    pod 'FirebaseAppIndexing', '1.2.0'
    pod 'FirebaseMessaging', '3.0.0'
    pod 'FirebaseAnalytics', '5.0.0'
    pod 'FirebaseRemoteConfig', '3.0.0'
    
    pod 'Amplitude-iOS', '~> 4.0.4'
    
    pod 'BEMCheckBox'

    # actual version - 6.x, we should test it before update
    pod 'IQKeyboardManagerSwift', '~> 5.0'

    pod 'Kanna', '~> 4.0.0'
    pod 'CRToast', :git => 'https://github.com/cruffenach/CRToast.git', :branch => 'master'
    pod 'TUSafariActivity', '~> 1.0'
    
    pod "VK-ios-sdk"
    pod 'FBSDKCoreKit'
    pod 'FBSDKLoginKit'
    
    pod 'Presentr', '1.3.0'
    
    pod 'Agrume', :git => 'https://github.com/Ostrenkiy/Agrume.git', :branch => 'feature/single-horizontal-dismiss'
    pod 'Highlightr', :git => 'https://github.com/raspu/Highlightr.git', :branch => 'master'
    pod "RFKeyboardToolbar", "~> 1.3"
    pod 'TTTAttributedLabel'
    pod 'PromiseKit', '~> 4.4'
    pod 'Atributika', '~> 4.0'
    pod 'DeviceKit', '~> 1.0'
    pod 'lottie-ios'
    pod 'Koloda', '4.3.1'
    pod 'Charts', '3.0.4'
    pod 'EasyTipView', :git => 'https://github.com/igorkislyuk/EasyTipView.git'
    pod 'ActionSheetPicker-3.0'
    pod 'NotificationBannerSwift'
end

def testing_pods
    pod 'Quick'
    pod 'Nimble'
end

def adaptive_pods
    pod 'SDWebImage/GIF'
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

target 'Adaptive 1838' do
    platform :ios, '9.0'
    all_pods
    adaptive_pods    
end

target 'Adaptive GMAT' do
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

target 'Adaptive 8290' do
    platform :ios, '9.0'
    all_pods
    adaptive_pods
end

target 'Adaptive 1838 Screenshots' do
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

