//
//  UIStackView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

extension UIStackView {
    func removeAllArrangedSubviews() {
        for subview in self.arrangedSubviews {
            self.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }
}
