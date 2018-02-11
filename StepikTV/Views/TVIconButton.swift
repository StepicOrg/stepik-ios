//
//  IconButton.swift
//  StepikTV
//
//  Created by Александр Пономарев on 29.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class TVIconButton: UIView {

    @IBOutlet private var button: UIButton!
    @IBOutlet private var label: UILabel!

    var isEnabled: Bool = true {
        didSet {
            button.isEnabled = isEnabled
        }
    }

    var action : (() -> Void)? {
        didSet {
            self.button.addTarget(self, action: #selector(pressedButton(_:)), for: .primaryActionTriggered)
        }
    }

    func configure(with icon: UIImage, _ title: String) {
        button.setImage(icon, for: .normal)
        label.text = title
    }

    func pressedButton(_ sender: UIButton) {
        if isEnabled { self.action?() }
    }
}
