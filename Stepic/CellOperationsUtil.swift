//
//  CellOperationsUtil.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit
import FLKAutoLayout 

/*
 Some custom cell operation util functions
 */
class CellOperationsUtil {
    class func addRefreshView(view: UIView, backgroundColor: UIColor = UIColor.whiteColor()) -> UIView {
        let v = UIView()
        v.backgroundColor = backgroundColor
        let ind = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        v.addSubview(ind)
        ind.alignCenterWithView(v)
        ind.startAnimating()
        view.addSubview(v)
        v.alignToView(view)
        return v
    }
}