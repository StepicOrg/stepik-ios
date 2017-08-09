//
//  TapProxyView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 09.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class TapProxyView: UIView {

    var targetView: UIView?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return self.bounds.contains(point) ? targetView : nil
    }
}
