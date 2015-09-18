//
//  UICustomizer.swift
//  Stepic
//
//  Created by Alexander Karpov on 18.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit

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
}
