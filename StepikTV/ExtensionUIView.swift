//
//  ExtensionUIView.swift
//  StepikTV
//
//  Created by Александр Пономарев on 24.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import Foundation

extension UIView {

    func align(to view: UIView) {
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    func align(to view: UIView, top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat) {
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leading).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailing).isActive = true
        self.topAnchor.constraint(equalTo: view.topAnchor, constant: top).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom).isActive = true
    }

    var allSubviews : [UIView] {
        var array = [self.subviews].flatMap { $0 }
            array.forEach { array.append(contentsOf: $0.allSubviews)}
        return array
    }
}
