install! "cocoapods", :deterministic_uuids => false
source "https://github.com/CocoaPods/Specs.git"

inhibit_all_warnings!
use_frameworks!

project "Stepic",
        "Production Debug" => :debug,
        "Production Release" => :release,
        "Release Debug" => :debug,
        "Release Release" => :release,
        "Develop Debug" => :debug,
        "Develop Release" => :release

def shared_pods
  pod "StepikModel", path: "./StepikModel"

  pod "Alamofire", "5.10.1"
  pod "Atributika", "4.10.1"
  pod "SwiftyJSON", "5.0.2"
  pod "SDWebImage", "5.19.7"
  pod "SVGKit", :git => "https://github.com/SVGKit/SVGKit.git", :branch => "3.x"
  pod "DeviceKit", "5.5.0"
  pod "PromiseKit", "8.0.0"
  pod "SwiftLint", "0.57.0"

  if ENV["FASTLANE_BETA_PROFILE"] == "true"
    pod "FLEX",
        :git => "https://github.com/ivan-magda/FLEX.git",
        :branch => "master"
  else
    pod "FLEX",
        :git => "https://github.com/ivan-magda/FLEX.git",
        :branch => "master",
        :configurations => ["Production Debug", "Release Debug", "Develop Debug"]
  end
end

def all_pods
  shared_pods

  pod "SVProgressHUD", "2.3.1"
  pod "SnapKit", "5.7.1"

  # Firebase
  pod "Firebase/Core", "10.29.0"
  pod "Firebase/Messaging", "10.29.0"
  pod "Firebase/Analytics", "10.29.0"
  pod "Firebase/Crashlytics", "10.29.0"
  pod "Firebase/RemoteConfig", "10.29.0"

  pod "AppMetricaCore", "5.8.2"
  pod "Amplitude", "8.22.0"
  pod "BranchSDK", "3.6.5"

  pod "BEMCheckBox", "1.4.1"

  pod "IQKeyboardManagerSwift", "6.5.6"

  pod "Kanna", "5.2.7"
  pod "TUSafariActivity", "1.0.4"

  # Social SDKs
  pod "VK-ios-sdk", "1.6.2"
  # pod "FBSDKCoreKit", "8.2.0"
  # pod "FBSDKLoginKit", "8.2.0"
  pod "GoogleSignIn", "6.1.0"

  pod "Presentr", :git => "https://github.com/ivan-magda/Presentr.git", :tag => "v1.9.1"
  pod "PanModal", :git => "https://github.com/ivan-magda/PanModal.git", :branch => "remove-presenting-appearance-transitions"

  pod "Agrume", "5.8.0"
  pod "Highlightr", :git => "https://github.com/ivan-magda/Highlightr.git", :tag => "v2.1.3"
  pod "TTTAttributedLabel", "2.0.0"
  pod "lottie-ios", "3.2.3"
  pod "Koloda", "5.0.1"
  pod "DGCharts", "5.1.0"
  pod "EasyTipView", "2.1.0"
  pod "ActionSheetPicker-3.0", "2.7.4"
  pod "Nuke", "10.7.1"
  pod "STRegex", "2.1.1"
  pod "Tabman", "3.2.0"
  pod "SwiftDate", "6.3.1"
end

def testing_pods
  pod "Quick", "4.0.0"
  pod "Nimble", "9.2.1"
  pod "Mockingjay", :git => "https://github.com/kylef/Mockingjay.git", :branch => "master"
end

target "Stepic" do
  platform :ios, "12.0"
  all_pods
  target "StepicTests" do
    inherit! :search_paths
    all_pods
    testing_pods
  end
end

post_install do |installer|
  # Fix Xcode 15 Error 'DT_TOOLCHAIN_DIR cannot be used to evaluate LIBRARY_SEARCH_PATHS, use TOOLCHAIN_DIR instead'
  installer.aggregate_targets.each do |target|
    target.xcconfigs.each do |variant, xcconfig|
      xcconfig_path = target.client_root + target.xcconfig_relative_path(variant)
      IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
    end
  end
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.base_configuration_reference.is_a? Xcodeproj::Project::Object::PBXFileReference
        xcconfig_path = config.base_configuration_reference.real_path
        IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
      end
    end
  end

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"].to_f < 12.0
        config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "12.0"
      end
    end

    # Fix Xcode 14 bundle code signing issue
    if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
      target.build_configurations.each do |config|
        config.build_settings["CODE_SIGNING_ALLOWED"] = "NO"
      end
    end
  end
end
