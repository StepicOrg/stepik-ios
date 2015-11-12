//
//  ImageViewExtension.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

extension UIImageView {
    func setImageWithColor(image i: UIImage, color: UIColor) {
        self.image = i
        self.image = i.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.tintColor = color
    }
}