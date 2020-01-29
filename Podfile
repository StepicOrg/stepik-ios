install! 'cocoapods', :deterministic_uuids => false
source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

def shared_pods
    pod 'Alamofire', '4.9.1'
    pod 'Atributika', '4.9.4'
    pod 'SwiftyJSON', '5.0.0'
    pod 'SDWebImage', '5.5.2'
    pod 'SVGKit', :git => 'https://github.com/SVGKit/SVGKit.git', :branch => '2.x'
    pod 'Logging', '1.2.0'
    pod 'Fabric', '1.10.2'
    pod 'Crashlytics', '3.14.0'
    pod 'DeviceKit', '3.0.0'
    pod 'PromiseKit', '6.13.0'
    pod 'SwiftLint', '0.38.2'
    pod 'Reveal-SDK', :configurations => ['Debug']
end

def all_pods
    shared_pods

    pod 'DownloadButton', '0.1.0'
    pod 'SVProgressHUD', '2.2.5'
    # TSMessages is no longer being maintained/updated, remove or migrate to RMessage/SwiftMessages
    pod 'TSMessages', :git => 'https://github.com/KrauseFx/TSMessages.git'

    pod 'SnapKit', '5.0.1'

    # Firebase
    pod 'Firebase/Core', '6.14.0'
    pod 'Firebase/Messaging' , '6.14.0'
    pod 'Firebase/Analytics' , '6.14.0'
    pod 'Firebase/RemoteConfig', '6.14.0'

    pod 'YandexMobileMetrica/Dynamic', '3.8.2'
    pod 'Amplitude-iOS', '4.9.3'
    pod 'Branch', '0.31.0'
        
    pod 'BEMCheckBox', '1.4.1'

    pod 'IQKeyboardManagerSwift', '6.5.4'

    pod 'Kanna', '5.0.0'
    # Remove after NotificationsService refactoring
    pod 'CRToast', '0.0.9'
    pod 'TUSafariActivity', '1.0.4'
    
    pod 'VK-ios-sdk', '1.5.1'
    pod 'FBSDKCoreKit', '5.13.0'
    pod 'FBSDKLoginKit', '5.13.0'
    
    pod 'Presentr', '1.9'
    
    pod 'Agrume', '5.6.1'
    pod 'Highlightr', '2.1.0'
    pod 'TTTAttributedLabel', '2.0.0'
    pod 'lottie-ios', '2.5.3'
    pod 'Koloda', '5.0'
    pod 'Charts', '3.4.0'
    pod 'EasyTipView', '2.0.4'
    pod 'ActionSheetPicker-3.0', '2.4.0'
    pod 'Nuke', '8.3.1'
    pod 'STRegex', '2.1.0'
    pod 'Tabman', '2.6.3'
    pod 'SwiftDate', '6.1.0'
end

def testing_pods
    pod 'Quick', '2.2.0'
    pod 'Nimble', '8.0.5'
    pod 'Mockingjay', '3.0.0-alpha.1'
end

target 'Stepic' do
    platform :ios, '11.0'
    all_pods
    target 'StepicTests' do
        inherit! :search_paths
        all_pods
        testing_pods
    end
end
