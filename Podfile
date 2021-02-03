install! 'cocoapods', :deterministic_uuids => false
source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

project 'Stepic',
        'Production Debug' => :debug,
        'Production Release' => :release,
        'Release Debug' => :debug,
        'Release Release' => :release,
        'Develop Debug' => :debug,
        'Develop Release' => :release

def shared_pods
  pod 'Alamofire', '5.4.1'
  pod 'Atributika', '4.9.10'
  pod 'SwiftyJSON', '5.0.0'
  pod 'SDWebImage', '5.10.4'
  pod 'SVGKit', :git => 'https://github.com/SVGKit/SVGKit.git', :branch => '2.x'
  pod 'DeviceKit', '4.2.1'
  pod 'PromiseKit', '6.13.1'
  pod 'SwiftLint', '0.42.0'
end

def all_pods
  shared_pods

  pod 'DownloadButton', '0.1.0'
  pod 'SVProgressHUD', '2.2.5'
  # TSMessages is no longer being maintained/updated, remove or migrate to RMessage/SwiftMessages
  pod 'TSMessages', :git => 'https://github.com/KrauseFx/TSMessages.git'

  pod 'SnapKit', '5.0.1'

  # Firebase
  pod 'Firebase/Core', '7.5.0'
  pod 'Firebase/Messaging', '7.5.0'
  pod 'Firebase/Analytics', '7.5.0'
  pod 'Firebase/Crashlytics', '7.5.0'
  pod 'Firebase/RemoteConfig', '7.5.0'

  pod 'YandexMobileMetrica/Dynamic', '3.14.1'
  pod 'Amplitude', '7.2.2'
  pod 'Branch', '0.31.0'

  pod 'BEMCheckBox', '1.4.1'

  pod 'IQKeyboardManagerSwift', '6.5.6'
  
  pod 'Kanna', '5.2.4'
  # Remove after NotificationsService refactoring
  pod 'CRToast', '0.0.9'
  pod 'TUSafariActivity', '1.0.4'

  # Social SDKs
  pod 'VK-ios-sdk', '1.6.2'
  pod 'FBSDKCoreKit', '8.2.0'
  pod 'FBSDKLoginKit', '8.2.0'
  pod 'GoogleSignIn', '5.0.2'

  pod 'Presentr', '1.9'
  pod 'PanModal', '1.2.7'

  pod 'Agrume', '5.6.12'
  pod 'Highlightr', '2.1.0'
  pod 'TTTAttributedLabel', '2.0.0'
  pod 'lottie-ios', '3.2.0'
  pod 'Koloda', '5.0.1'
  pod 'Charts', '3.6.0'
  pod 'EasyTipView', '2.1.0'
  pod 'ActionSheetPicker-3.0', '2.7.1'
  pod 'Nuke', '9.2.4'
  pod 'STRegex', '2.1.1'
  pod 'Tabman', '2.10.0'
  pod 'SwiftDate', '6.3.1'
end

def testing_pods
  pod 'Quick', '3.0.0'
  pod 'Nimble', '9.0.0'
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