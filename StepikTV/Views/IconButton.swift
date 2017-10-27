//
//  IconButton.swift
//  StepikTV
//
//  Created by Александр Пономарев on 29.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class IconButton: UIView {

    @IBOutlet var button: UIButton!

    @IBOutlet var label: UILabel!

    override var preferredFocusEnvironments: [UIFocusEnvironment] { get { return [button] } }

    func configure(with icon: UIImage, _ title: String) {
        button.setImage(icon, for: .normal)
        label.text = title
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)

    }

}
