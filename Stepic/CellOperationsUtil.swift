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
    
    //Returns the removeSelection block
    class func animateViewSelection(view: UIView) -> (Void->Void) {
        let selectedColor = UIColor(red: 217/255.0, green: 217/255.0, blue: 217/255.0, alpha: 1).CGColor
        UIView.animateWithDuration(0.5, animations: {
            view.layer.backgroundColor = selectedColor
        })
        
        return {
            UIView.animateWithDuration(0.5, animations: {
                view.layer.backgroundColor = UIColor.whiteColor().CGColor
            })
        }
    }
}