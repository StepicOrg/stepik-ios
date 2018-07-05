//
//  UIViewController+fromNib.swift
//  Stepic
//
//  Created by Ivan Magda on 05/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit.UIViewController

extension UIViewController {
    
    class func fromNib<T: UIViewController>() -> T {
        return T(nibName: String(describing: T.self), bundle: nil)
    }
    
    class func fromNib<T: UIViewController>(named nibName: String, bundle: Bundle? = nil) -> T {
        return T(nibName: nibName, bundle: bundle)
    }
    
}
