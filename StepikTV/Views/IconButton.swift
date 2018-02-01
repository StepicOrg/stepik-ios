//
//  IconButton.swift
//  StepikTV
//
//  Created by Александр Пономарев on 29.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

protocol IconButtonDelegate {
    func iconButtonPressed(sender : IconButton)
}

class IconButton: UIView {

    @IBOutlet public private(set) var button: UIButton!
    @IBOutlet var label: UILabel!

    func configure(with icon: UIImage, _ title: String) {
        button.setImage(icon, for: .normal)
        label.text = title
    }
}
