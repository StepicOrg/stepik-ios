//
//  AvatarImageView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 29.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Alamofire
import SVGKit

class AvatarImageView: UIImageView {

    private let colors: [Int] = [0x005b96, 0xe39e54, 0xd64d4d, 0x4d7358, 0x885159, 0x886451]

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setRoundedBounds(width: 0)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        image = Constants.placeholderImage
    }

    func set(with url: URL) {
        if url.pathExtension != "svg" {
            self.sd_setImage(with: url, placeholderImage: self.image)
        } else {
            Alamofire.request(url).responseData(completionHandler: { response in
                if response.result.error != nil {
                    return
                }

                guard let data = response.result.value else {
                    return
                }

                DispatchQueue.global(qos: .userInitiated).async {
                    var img: UIImage? = nil

                    if let svgString = String(data: data, encoding: String.Encoding.utf8),
                       let letters = self.extractLetters(from: svgString) {
                        // Draw custom avatar
                        img = self.renderImage(with: letters)
                    } else {
                        // Render SVG
                        let svgImage = SVGKImage(data: data)
                        if !(svgImage?.hasSize() ?? true) {
                            svgImage?.size = CGSize(width: 200, height: 200)
                        }
                        img = svgImage?.uiImage
                    }

                    DispatchQueue.main.async {
                        self.image = img ?? self.image
                    }
                }

            })
        }
    }

    private func renderImage(with letters: String) -> UIImage? {
        let label = UILabel()
        label.frame.size = self.bounds.size
        label.font = label.font.withSize(self.bounds.size.height / 3.0)
        label.textColor = UIColor.white
        label.text = letters
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = UIColor(hex: colors[letters.hash % colors.count])

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, scale)
        if let context = UIGraphicsGetCurrentContext() {
            label.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        } else {
            return nil
        }
    }

    private func extractLetters(from svgString: String) -> String? {
        let xmlWOClosingTags = svgString.replacingOccurrences(of: "</text></svg>", with: "")
        let letters = xmlWOClosingTags.components(separatedBy: ">").last
        return letters
    }

}
