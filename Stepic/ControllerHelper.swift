//
//  ControllerHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 10.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

struct ControllerHelper {
    static func showLaunchController(animated: Bool) -> LaunchViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("LaunchViewController") as! LaunchViewController
        var topVC = UIApplication.sharedApplication().keyWindow?.rootViewController
        while((topVC!.presentedViewController) != nil){
            topVC = topVC!.presentedViewController
        }
        topVC?.presentViewController(vc, animated: animated, completion: {
            //            self.dismissViewControllerAnimated(false, completion: nil)
        })
        return vc
    }
}