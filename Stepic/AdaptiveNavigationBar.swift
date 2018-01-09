//
//  AdaptiveNavigationBar.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 09.01.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class AdaptiveNavigationBar: NibInitializableView {

    override var nibName: String {
        return "AdaptiveNavigationBar"
    }

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var expLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!

    var onCloseAction: (() -> Void)?
    var onTrophyAction: (() -> Void)?

    override func layoutSubviews() {
        navigationBar.barTintColor = UIColor.mainLight
    }

    @IBAction func onCloseButtonClick(_ sender: Any) {
        onCloseAction?()
    }

    @IBAction func onTrophyButtonClick(_ sender: Any) {
        onTrophyAction?()
    }
}

