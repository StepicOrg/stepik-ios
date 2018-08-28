//
//  StoryCollectionViewCell.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 06.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import UIKit
import Nuke

final class StoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    let cornerRadius: CGFloat = 16
    let unwatchedColor: UIColor = UIColor.mainDark

    var imagePath: String = "" {
        didSet {
            if let url = URL(string: imagePath) {
                Nuke.loadImage(with: url, options: .shared, into: imageView)
            }
        }
    }

    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }

    var isWatched: Bool = true {
        didSet {
            updateWatched()
        }
    }

    private func updateWatched() {
        self.layer.borderColor = isWatched ? UIColor.mainLight.cgColor : unwatchedColor.cgColor
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = cornerRadius
        self.contentView.layer.borderWidth = 4
        self.contentView.layer.borderColor = UIColor.white.cgColor
        self.contentView.clipsToBounds = true
        self.contentView.layer.masksToBounds = true

        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = 2
        self.layer.borderColor = unwatchedColor.cgColor
        self.clipsToBounds = true
        self.layer.masksToBounds = true

        update(imagePath: imagePath, title: title, isWatched: isWatched)
    }

    func update(imagePath: String, title: String, isWatched: Bool) {
        self.imagePath = imagePath
        self.title = title
        self.isWatched = isWatched
    }
}
