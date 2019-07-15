# Uncomment this line to define a global platform for your project
install! 'cocoapods', :deterministic_uuids => false
source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

def shared_pods
    pod 'Alamofire', '4.8.2'
    pod 'Atributika', '4.8.2'
    pod 'SwiftyJSON', '4.1.0'
    pod 'SDWebImage', '4.4.2'
    pod 'SVGKit', :git => 'https://github.com/SVGKit/SVGKit.git', :branch => '2.x'
    pod 'Fabric', '1.7.11'
    pod 'Crashlytics', '3.10.7'
    pod 'DeviceKit', '1.10.0'
    pod 'PromiseKit', '6.8.4'
    pod 'SwiftLint', '0.31.0'
    pod 'Reveal-SDK', :configurations => ['Debug']
end

def all_pods

    shared_pods
    pod 'DownloadButton', '0.1.0'
    pod 'SVProgressHUD', '2.2.5'
    pod 'TSMessages', :git => 'https://github.com/KrauseFx/TSMessages.git'
    pod 'YandexMobileMetrica/Dynamic', '3.2.0'

    pod 'SnapKit', '4.2.0'
    
    pod 'FirebaseCore', '5.1.0'
    pod 'FirebaseMessaging' , '3.1.0'
    pod 'FirebaseAnalytics' , '5.1.0'
    pod 'FirebaseRemoteConfig', '3.0.1'

    pod 'Amplitude-iOS', '4.3.0'
        
    pod 'BEMCheckBox', '1.4.1'

    pod 'IQKeyboardManagerSwift', '6.2.1'

    pod 'Kanna', '4.0.1'
    pod 'CRToast', '0.0.9'
    pod 'TUSafariActivity', '1.0.4'
    
    pod 'VK-ios-sdk', '1.4.6'
    pod 'FBSDKCoreKit', '4.35.0'
    pod 'FBSDKLoginKit', '4.35.0'
    
    pod 'Presentr', '1.3.2'
    
    pod 'Agrume', :git => 'https://github.com/JanGorman/Agrume.git'
    pod 'Highlightr', '2.1.0'
    pod 'RFKeyboardToolbar', '1.3'
    pod 'TTTAttributedLabel', '2.0.0'
    pod 'lottie-ios', '2.5.0'
    pod 'Koloda', '4.7'
    pod 'Charts', '3.2.2'
    pod 'EasyTipView', '2.0.4'
    pod 'ActionSheetPicker-3.0', '2.3.0'
    pod 'NotificationBannerSwift', '2.0.1'
    pod 'Nuke', '7.3.2'
    pod 'STRegex', '2.0.0'
    pod 'Tabman', '2.4.1' 
    pod 'Branch', '0.25.5'
end

def testing_pods
    pod 'Quick', '1.3.1'
    pod 'Nimble', '8.0.1'
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
