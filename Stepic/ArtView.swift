//
//  ArtView.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class ArtView: NibInitializableView {
    @IBOutlet weak var titleLabel: UILabel!

    override var nibName: String {
        return "ArtView"
    }

    var onVKClick: (() -> Void)?
    var onFacebookClick: (() -> Void)?
    var onInstagramClick: (() -> Void)?

    override func setupSubviews() {
        super.setupSubviews()
        self.titleLabel.text = NSLocalizedString("OurSocialNetworks", comment: "")
    }

    @IBAction func vkButtonPressed(_ sender: Any) {
        self.onVKClick?()
    }

    @IBAction func fbButtonPressed(_ sender: Any) {
        self.onFacebookClick?()
    }

    @IBAction func instagramButtonPressed(_ sender: Any) {
        self.onInstagramClick?()
    }
}
