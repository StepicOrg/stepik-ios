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

    enum Shape {
        case rectangle(cornerRadius: CGFloat)
        case circle
    }

    private let colors: [Int] = [0x69A1E5, 0xFFD19F, 0xE8B9B9, 0x85C096, 0xE1B3EA, 0xABE5D8]

    var shape: Shape = .circle {
        didSet {
            updateShape()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateShape()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        image = Constants.placeholderImage
    }

    private func updateShape() {
        switch shape {
        case .circle:
            self.setRoundedBounds(width: 0)
        case .rectangle(let radius):
            self.setRoundedCorners(cornerRadius: radius, borderWidth: 0)
        }
    }

    func set(with url: URL) {
        if url.pathExtension != "svg" {
            self.sd_setImage(with: url, placeholderImage: self.image)
        } else {
            AlamofireDefaultSessionManager.shared.request(url).responseData(completionHandler: { response in
                if response.result.error != nil {
                    return
                }

                guard let data = response.result.value else {
                    return
                }

                DispatchQueue.global(qos: .userInitiated).async {
                    if let svgString = String(data: data, encoding: String.Encoding.utf8),
                       let letters = self.extractLetters(from: svgString) {
                        // Draw custom avatar
                        DispatchQueue.main.async {
                            self.image = self.renderImage(with: letters) ?? self.image
                        }
                    } else {
                        // Render SVG
                        let svgImage = SVGKImage(data: data)
                        if !(svgImage?.hasSize() ?? true) {
                            svgImage?.size = CGSize(width: 200, height: 200)
                        }
                        DispatchQueue.main.async {
                            self.image = svgImage?.uiImage ?? self.image
                        }
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
        if let letters = xmlWOClosingTags.components(separatedBy: ">").last {
            return letters.count <= 2 ? letters : nil
        }
        return nil
    }

}
