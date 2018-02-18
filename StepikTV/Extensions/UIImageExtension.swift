//
//  UIImageExtension.swift
//  StepikTV
//
//  Created by Александр Пономарев on 11.02.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

extension UIImage {

    func imageSizeThatAspectFills(rect: CGRect) -> CGRect {
        let aspect = self.size.width / self.size.height
        if rect.size.width / aspect > rect.size.height {
            let height = rect.size.width / aspect
            return CGRect(x: 0, y: (rect.size.height - height) / 2, width: rect.size.width, height: height)
        } else {
            let width = rect.size.height * aspect
            return CGRect(x: (rect.size.width - width) / 2, y: 0, width: width, height: rect.size.height)
        }
    }

    func getRoundedCornersImage(cornerRadius radius: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        let rect = CGRect(origin: .zero, size: self.size)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
            path.addClip()

        self.draw(in: rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
