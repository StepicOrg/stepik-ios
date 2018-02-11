//
//  ItemCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 11.02.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class ImageConvertableCollectionViewCell: UICollectionViewCell {

    var isGradientNeeded: Bool = true

    private func getGradientLayer() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [UIColor.black.withAlphaComponent(0.1).cgColor, UIColor.black.withAlphaComponent(0.3).cgColor, UIColor.black.withAlphaComponent(0.6).cgColor]

        return gradient
    }

    func getTextAttributes() -> [String: Any] {
        return [:]
    }

    func getTextRect(_ text: String) -> CGRect {
        return CGRect.zero
    }

    func getAdditionalTextAttributes() -> [String: Any] {
        return [:]
    }

    func getAdditionalTextRect(_ text: String) -> CGRect {
        return CGRect.zero
    }

    final func generateImage(with text: String, additionalText: String? = nil, inImage image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)

        let imageRect = image.imageSizeThatAspectFills(rect: self.bounds)
        image.draw(in: imageRect)

        let gradient = getGradientLayer()
        if isGradientNeeded { gradient.render(in: UIGraphicsGetCurrentContext()!) }

        let textRect = getTextRect(text)
        let textAttributes = getTextAttributes()
        text.draw(in: textRect, withAttributes: textAttributes)

        if let additionalText = additionalText {
            let adTextRect = getAdditionalTextRect(text)
            let adTextAttributes = getAdditionalTextAttributes()
            additionalText.draw(in: adTextRect, withAttributes: adTextAttributes)
        }

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

}
