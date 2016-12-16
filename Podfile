# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

def all_pods
    pod 'Alamofire', :git => 'https://github.com/Homely/Alamofire.git', :branch => 'ios8'
    pod 'SwiftyJSON', '3.1.0'
    pod 'SDWebImage'
    pod 'TextFieldEffects'
    pod "DownloadButton"
    pod 'SVProgressHUD'
    pod 'FLKAutoLayout', '0.2.1'
    pod 'TSMessages', :git => 'https://github.com/KrauseFx/TSMessages.git'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'DZNEmptyDataSet'
    
#    pod 'YandexMobileMetrica/Dynamic', '2.6.2'

    pod 'Firebase', '<= 3.4.0'
#    pod 'Firebase/Messaging'
    pod 'FirebaseAppIndexing', '1.0.4'
    pod 'FirebaseMessaging', '1.1.1'
    pod 'FirebaseAnalytics', '3.3.0'
#    pod 'Firebase/Core'
    
    pod "MagicalRecord"
    pod 'BEMCheckBox'
    pod 'IQKeyboardManagerSwift'
    pod 'Kanna', '~> 2.0.0'
    pod 'CRToast'
    pod 'TUSafariActivity', '~> 1.0'
    
    pod "VK-ios-sdk" 
    pod 'FBSDKCoreKit'
    pod 'FBSDKLoginKit'
    
end

#post_install do |installer|
#    appmetricaPlistPath = "Pods/YandexMobileMetrica/dynamic/YandexMobileMetrica.framework/Info.plist"
#    appmetricaVersion = `/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' #{appmetricaPlistPath}`.strip
#    if ['2.6.0', '2.6.1', '2.6.2'].include? appmetricaVersion
#        system("/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier org.cocoapods.YandexMobileMetrica' #{appmetricaPlistPath}")
#        system("plutil -convert binary1 #{appmetricaPlistPath}")
#        else
#        puts("Please, remove workaround for AppMetrica dynamic framework.")
#    end
#end

target 'Stepic' do
    all_pods
    target 'StepicTests' do
        inherit! :search_paths
        all_pods
    end
end

target 'SberbankUniversity' do 
    all_pods
end
