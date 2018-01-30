//
//  TVUnavailableQuizViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 26.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class TVUnavailableQuizViewController: TVQuizViewController {

    var textLabel: UILabel!

    private let textLabelPlaceholder: String = NSLocalizedString("This quiz is unavailable on AppleTV", comment: "")

    override func viewDidLoad() {
        super.viewDidLoad()

        textLabel = UILabel(frame: CGRect.zero)

        textLabel.text = textLabelPlaceholder
        textLabel.textAlignment = .center
        textLabel.textColor = UIColor.white
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFont(ofSize: 40, weight: UIFontWeightMedium)

        containerView.addSubview(textLabel)
        view.sizeToFit()
        textLabel.align(to: containerView)
        view.sizeToFit()
    }

}
