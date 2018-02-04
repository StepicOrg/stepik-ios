//
//  IconButton.swift
//  StepikTV
//
//  Created by Александр Пономарев on 29.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

<<<<<<< HEAD:StepikTV/Views/IconButton.swift
class IconButton: UIView {
=======
class TVIconButton: UIView {
>>>>>>> fix/course-content-to-info-units-buttons-behavior:StepikTV/Views/TVIconButton.swift

    @IBOutlet private(set) var button: UIButton!
    @IBOutlet private var label: UILabel!

    var action : (() -> Void)? {
        didSet {
            self.button.removeTarget(self, action: #selector(pressedVideoButton(_:)), for: .primaryActionTriggered)
            self.button.addTarget(self, action: #selector(pressedVideoButton(_:)), for: .primaryActionTriggered)
        }
    }

    func configure(with icon: UIImage, _ title: String) {
        button.setImage(icon, for: .normal)
        label.text = title
    }

    func pressedVideoButton(_ sender: UIButton) {
        self.action?()
    }

}
