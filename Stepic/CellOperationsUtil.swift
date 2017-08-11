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

    class func addRefreshView(_ view: UIView, backgroundColor: UIColor = UIColor.white) -> UIView {
        let v = UIView()
        v.backgroundColor = backgroundColor
        let ind = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        v.addSubview(ind)
        ind.alignCenter(with: v)
        ind.startAnimating()
        view.addSubview(v)
        v.align(to: view)
        return v
    }

    //Returns the removeSelection block
    class func animateViewSelection(_ view: UIView) -> (() -> Void) {
        let selectedColor = UIColor(red: 217/255.0, green: 217/255.0, blue: 217/255.0, alpha: 1).cgColor
        UIView.animate(withDuration: 0.5, animations: {
            view.layer.backgroundColor = selectedColor
        })

        return {
            UIView.animate(withDuration: 0.5, animations: {
                view.layer.backgroundColor = UIColor.white.cgColor
            })
        }
    }
}
