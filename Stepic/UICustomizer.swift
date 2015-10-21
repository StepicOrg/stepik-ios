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
    
    func setCustomDownloadButton(button: PKDownloadButton) {
        button.startDownloadButton?.cleanDefaultAppearance()
        button.startDownloadButton?.setBackgroundImage(Images.downloadFromCloud, forState: .Normal)
        
        //button.stopDownloadButton is default!
        
        button.downloadedButton?.cleanDefaultAppearance()
        button.downloadedButton?.setBackgroundImage(Images.delete, forState: .Normal)
    }
}
