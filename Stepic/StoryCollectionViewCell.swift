//
//  StoryCollectionViewCell.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 06.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import Nuke
import UIKit

final class StoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    let cornerRadius: CGFloat = 16
    let unwatchedColor = UIColor.stepikAccent

    var imagePath: String = "" {
        didSet {
            if let url = URL(string: imagePath) {
                Nuke.loadImage(with: url, options: .shared, into: self.imageView)
            }
        }
    }

    var title: String = "" {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var isWatched: Bool = true {
        didSet {
            self.updateWatched()
        }
    }

    private func updateWatched() {
        self.layer.borderColor = self.isWatched ? UIColor.stepikGrey.cgColor : self.unwatchedColor.cgColor
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.contentView.layer.cornerRadius = self.cornerRadius
        self.contentView.layer.borderWidth = 4
        self.contentView.layer.borderColor = UIColor.white.cgColor
        self.contentView.clipsToBounds = true
        self.contentView.layer.masksToBounds = true

        self.layer.cornerRadius = self.cornerRadius
        self.layer.borderWidth = 2
        self.layer.borderColor = self.unwatchedColor.cgColor
        self.clipsToBounds = true
        self.layer.masksToBounds = true

        self.update(imagePath: self.imagePath, title: self.title, isWatched: self.isWatched)
    }

    func update(imagePath: String, title: String, isWatched: Bool) {
        self.imagePath = imagePath
        self.title = title
        self.isWatched = isWatched
    }
}
