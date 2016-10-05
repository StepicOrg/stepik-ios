//
//  ReplaceLastSegue.swift
//  Stepic
//
//  Created by Alexander Karpov on 23.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class ReplaceLastSegue: UIStoryboardSegue {
    override func perform() {
        if let vcs = source.navigationController?.viewControllers {
            var controllers = vcs
            controllers.popLast()
            controllers.append(destination)
            source.navigationController?.setViewControllers(controllers, animated: true)
        } 
    }
}
