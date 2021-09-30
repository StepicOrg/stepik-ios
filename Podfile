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
  pod 'Alamofire', '5.4.4'
  pod 'Atributika', '4.10.1'
  pod 'SwiftyJSON', '5.0.0'
  pod 'SDWebImage', '5.11.0'
  pod 'SVGKit', :git => 'https://github.com/SVGKit/SVGKit.git', :branch => '2.x'
  pod 'DeviceKit', '4.5.0'
  pod 'PromiseKit', '6.15.3'
  pod 'SwiftLint', '0.44.0'

  if ENV['FASTLANE_BETA_PROFILE'] == 'true'
    pod 'FLEX',
        :git => 'https://github.com/ivan-magda/FLEX.git',
        :branch => 'master'
  else
    pod 'FLEX',
        :git => 'https://github.com/ivan-magda/FLEX.git',
        :branch => 'master',
        :configurations => ['Production Debug', 'Release Debug', 'Develop Debug']
  end
end

def all_pods
  shared_pods

  pod 'DownloadButton', '0.1.0'
  pod 'SVProgressHUD', '2.2.5'

  pod 'SnapKit', '5.0.1'

  # Firebase
  pod 'Firebase/Core', '8.7.0'
  pod 'Firebase/Messaging', '8.7.0'
  pod 'Firebase/Analytics', '8.7.0'
  pod 'Firebase/Crashlytics', '8.7.0'
  pod 'Firebase/RemoteConfig', '8.7.0'

  pod 'YandexMobileMetrica/Dynamic', '3.17.0'
  pod 'Amplitude', '8.3.1'
  pod 'Branch', '1.39.3'

  pod 'BEMCheckBox', '1.4.1'

  pod 'IQKeyboardManagerSwift', '6.5.6'

  pod 'Kanna', '5.2.7'
  pod 'TUSafariActivity', '1.0.4'

  # Social SDKs
  pod 'VK-ios-sdk', '1.6.2'
  pod 'FBSDKCoreKit', '8.2.0'
  pod 'FBSDKLoginKit', '8.2.0'
  pod 'GoogleSignIn', '5.0.2'

  pod 'Presentr', :git => 'https://github.com/ivan-magda/Presentr.git', :tag => 'v1.9.1'
  pod 'PanModal', :git => 'https://github.com/ivan-magda/PanModal.git', :branch => 'remove-presenting-appearance-transitions'

  pod 'Agrume', '5.6.13'
  pod 'Highlightr', :git => 'https://github.com/ivan-magda/Highlightr.git', :tag => 'v2.1.3'
  pod 'TTTAttributedLabel', '2.0.0'
  pod 'lottie-ios', '3.2.3'
  pod 'Koloda', '5.0.1'
  pod 'Charts', '3.6.0'
  pod 'EasyTipView', '2.1.0'
  pod 'ActionSheetPicker-3.0', '2.7.1'
  pod 'Nuke', '9.5.0'
  pod 'STRegex', '2.1.1'
  pod 'Tabman', '2.10.0'
  pod 'SwiftDate', '6.3.1'
end

def testing_pods
  pod 'Quick', '4.0.0'
  pod 'Nimble', '9.2.1'
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

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 9.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
  end
end
