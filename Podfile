# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

def all_pods
    pod 'Alamofire', '2.0.2'
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
    pod 'Google/Analytics'
    pod 'Google/CloudMessaging'
    pod 'AAShareBubbles'
    pod 'BEMCheckBox'
    pod 'IQKeyboardManagerSwift'
    pod 'Kanna'
    pod 'CRToast'
    pod 'TTTAttributedLabel'
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
