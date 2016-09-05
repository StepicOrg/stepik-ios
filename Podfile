# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

def all_pods
    pod 'Alamofire'
    pod 'SwiftyJSON'
    pod 'SDWebImage'
    pod 'TextFieldEffects'
    pod "DownloadButton"
    pod 'SVProgressHUD'
    pod 'FLKAutoLayout', '0.2.1'
    pod 'TSMessages', :git => 'https://github.com/KrauseFx/TSMessages.git'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'DZNEmptyDataSet'
    pod 'AFImageHelper'
    
    pod 'Firebase', '<= 3.4.0'
#    pod 'Firebase/Messaging'
    pod 'FirebaseAppIndexing', '1.0.4'
    pod 'FirebaseMessaging', '1.1.1'
    pod 'FirebaseAnalytics', '3.3.0'
#    pod 'Firebase/Core'
    
    pod "MagicalRecord"
    pod 'AAShareBubbles'
    pod 'BEMCheckBox'
    pod 'IQKeyboardManagerSwift'
    pod 'Kanna', '1.0.6'
    pod 'CRToast'
    pod 'TUSafariActivity', '~> 1.0'
end

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
