//
//  ControllerHelperLaunchExtension.swift
//  Stepic
//
//  Created by Alexander Karpov on 15.03.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

extension ControllerHelper {
    static func showLaunchController(animated: Bool)  {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("LaunchViewController") as! LaunchViewController
    
        getTopViewController()?.presentViewController(vc, animated: animated, completion: {
        //            self.dismissViewControllerAnimated(false, completion: nil)
        })
    }
}