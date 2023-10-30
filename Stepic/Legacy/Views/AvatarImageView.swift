//
//  AvatarImageView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 29.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Alamofire
import SnapKit
import SVGKit
import UIKit

final class AvatarImageView: UIImageView {
    private static let colorsLight: [UInt32] = [0x69A1E5, 0xFFD19F, 0xE8B9B9, 0x85C096, 0xE1B3EA, 0xABE5D8]
    private static let colorsDark: [UInt32] = [0x184D8E, 0xCF6B00, 0x9C3333, 0x376B46, 0x8E2CA1, 0x2F9881]

    var shape: Shape = .circle() {
        didSet {
            self.updateShape()
        }
    }

    private var colors: [UInt32] {
        self.isDarkInterfaceStyle ? Self.colorsDark : Self.colorsLight
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateShape()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.reset()
    }

    private func updateShape() {
        switch self.shape {
        case .circle(let borderWidth, let borderColor):
            self.setRoundedBounds(width: borderWidth, color: borderColor)
        case .rectangle(let radius):
            self.setRoundedCorners(cornerRadius: radius, borderWidth: 0)
        }
    }

    func reset() {
        self.image = UIImage(named: "lesson_cover_50")
    }

    func set(with url: URL) {
        if url.pathExtension == "svg" {
            AlamofireDefaultSessionManager
                .shared
                .request(url)
                .responseData { dataResponse in
                    guard let data = dataResponse.data else {
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
                }
        } else {
            self.sd_setImage(with: url, placeholderImage: self.image)
        }
    }

    private func renderImage(with letters: String) -> UIImage? {
        let label = UILabel()
        label.frame.size = self.bounds.size
        label.font = label.font.withSize(self.bounds.size.height / 3.0)
        label.textColor = UIColor.white
        label.text = letters
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = UIColor(hex6: self.colors[letters.hash % self.colors.count])

        if label.bounds.size == .zero {
            return nil
        }

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

    // MARK: Inner Types

    enum Shape {
        case rectangle(cornerRadius: CGFloat)
        case circle(borderWidth: CGFloat = 0, borderColor: UIColor = .white)
    }
}
