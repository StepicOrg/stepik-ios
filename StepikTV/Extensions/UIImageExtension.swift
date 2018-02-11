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

        if (rect.width / aspect <= rect.height) {
            let size = CGSize(width: rect.height / aspect, height: rect.height)
            let point = CGPoint(x: (rect.width - size.width) / 2, y: 0)
            return CGRect(origin: point, size: size)
        } else {
            let size = CGSize(width: rect.width, height: rect.width * aspect)
            let point = CGPoint(x: 0, y: (rect.height - size.height) / 2)
            return CGRect(origin: point, size: size)
        }
    }
}
