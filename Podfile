# Uncomment this line to define a global platform for your project
install! 'cocoapods', :deterministic_uuids => false
source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

def shared_pods
    pod 'Alamofire', '4.7.3'
    pod 'Atributika', '4.6.1'
    pod 'SwiftyJSON', '4.1.0'
    pod 'SDWebImage', '4.4.2'
    pod 'SVGKit', :git => 'https://github.com/SVGKit/SVGKit.git', :branch => '2.x'
    pod 'Fabric', '1.7.11'
    pod 'Crashlytics', '3.10.7'
    pod 'DeviceKit', '1.7.0'
    pod 'PromiseKit', '6.3.4'
    pod 'SwiftLint', '0.27.0'
end

def all_pods

    shared_pods
    pod 'DownloadButton', '0.1.0'
    pod 'SVProgressHUD', '2.2.5'
    pod 'TSMessages', :git => 'https://github.com/KrauseFx/TSMessages.git'
    pod 'YandexMobileMetrica/Dynamic', '3.2.0'

    pod 'SnapKit', '4.0.0'
    
    pod 'FirebaseCore', '5.1.0'
    pod 'FirebaseAppIndexing', '1.2.0'
    pod 'FirebaseMessaging', '3.1.0'
    pod 'FirebaseAnalytics', '5.1.0'
    pod 'FirebaseRemoteConfig', '3.0.1'
    
    pod 'Amplitude-iOS', '4.3.0'
    
    pod 'AppsFlyerFramework', '4.8.8'
    
    pod 'BEMCheckBox', '1.4.1'

    # actual version - 6.x, we should test it before update
    pod 'IQKeyboardManagerSwift', '5.0.8'

    pod 'Kanna', '4.0.1'
    pod 'CRToast', '0.0.9'
    pod 'TUSafariActivity', '1.0.4'
    
    pod 'VK-ios-sdk', '1.4.6'
    pod 'FBSDKCoreKit', '4.35.0'
    pod 'FBSDKLoginKit', '4.35.0'
    
    pod 'Presentr', '1.3.2'
    
    pod 'Agrume', :git => 'https://github.com/Ostrenkiy/Agrume.git', :branch => 'feature/single-horizontal-dismiss'
    pod 'Highlightr', '2.0.1'
    pod 'RFKeyboardToolbar', '1.3'
    pod 'TTTAttributedLabel', '2.0.0'
    pod 'lottie-ios', '2.5.0'
    pod 'Koloda', '4.3.1'
    pod 'Charts', '3.1.1'
    pod 'EasyTipView', :git => 'https://github.com/igorkislyuk/EasyTipView.git'
    pod 'ActionSheetPicker-3.0', '2.3.0'
    pod 'NotificationBannerSwift', '1.6.3'
    pod 'Nuke', '7.3.2'
end

def testing_pods
    pod 'Quick', '1.3.1'
    pod 'Nimble', '7.1.3'
end

def adaptive_pods
    pod 'SDWebImage/GIF', '4.4.2'
end

target 'Stepic' do
    platform :ios, '9.0'
    all_pods
    target 'StepicTests' do
        inherit! :search_paths
        all_pods
        testing_pods
		pod 'Mockingjay', '2.0.1'
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

target 'ExamEGERussian' do
    platform :ios, '9.0'
    
    all_pods
    pod 'AlamofireNetworkActivityIndicator', '2.2.1'
    pod 'PromiseKit/Alamofire', '6.3.4'

    target 'ExamEGERussianTests' do
        inherit! :search_paths
    end
end

