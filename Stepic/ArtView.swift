//
//  ArtView.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class ArtView: NibInitializableView {

    @IBOutlet weak var artImageView: UIImageView!
    @IBOutlet weak var artImageViewWidth: NSLayoutConstraint!

    var onTap : (() -> Void)?

    var art: UIImage? {
        didSet {
            artImageView.image = art
        }
    }

    var width: CGFloat = 0 {
        didSet {
            artImageViewWidth.constant = width - 48
        }
    }

    override var nibName: String {
        return "ArtView"
    }

    override func setupSubviews() {
        artImageView.image = art
        artImageView.isUserInteractionEnabled = true
        let tapG = UITapGestureRecognizer(target: self, action: #selector(ArtView.didTap))
        self.artImageView.addGestureRecognizer(tapG)
    }

    @objc func didTap() {
        onTap?()
    }
}
