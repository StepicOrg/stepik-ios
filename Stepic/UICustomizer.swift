//
//  UICustomizer.swift
//  Stepic
//
//  Created by Alexander Karpov on 18.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import DownloadButton

class UICustomizer: NSObject {
    static var sharedCustomizer = UICustomizer()
    private override init() {}
    
    func setStepicNavigationBar(navigationBar: UINavigationBar?) {
        if let bar = navigationBar {
            bar.barTintColor = UIColor.stepicGreenColor()
            bar.translucent = false
            bar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
            bar.tintColor = UIColor.whiteColor()
        }
    }
    
    func setStepicTabBar(tabBar: UITabBar?) {
        if let bar = tabBar {
            bar.tintColor = UIColor.stepicGreenColor()
            bar.translucent = false
        }
    }
    
    func setCustomDownloadButton(button: PKDownloadButton, white : Bool = false) {
        button.startDownloadButton?.cleanDefaultAppearance()
        button.startDownloadButton?.setBackgroundImage(white ? Images.downloadFromCloudWhite : Images.downloadFromCloud, forState: .Normal)
                
        if white {
            button.stopDownloadButton?.tintColor = UIColor.whiteColor()
        }
        
        button.downloadedButton?.cleanDefaultAppearance()
        button.downloadedButton?.setBackgroundImage(white ? Images.deleteWhite : Images.delete, forState: .Normal)
    }
}
