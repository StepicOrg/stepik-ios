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

    private let textLabelPlaceholder = NSLocalizedString("This quiz is unavailable on AppleTV", comment: "")

    override func viewDidLoad() {
        super.viewDidLoad()

        textLabel = UILabel(frame: CGRect.zero)

        textLabel.text = textLabelPlaceholder
        textLabel.textAlignment = .center
        textLabel.textColor = UIColor.white
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFont(ofSize: 40, weight: .medium)

        containerView.addSubview(textLabel)
        view.sizeToFit()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.align(to: containerView)
        view.sizeToFit()
    }

}
