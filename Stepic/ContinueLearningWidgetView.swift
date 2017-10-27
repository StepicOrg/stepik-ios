//
//  ContinueLearningWidgetView.swift
//  Stepic
//
//  Created by Ostrenkiy on 27.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class ContinueLearningWidgetView: NibInitializableView {

    @IBOutlet weak var continueLearningButton: UIButton!
    @IBOutlet weak var courseImageImageView: UIImageView!
    @IBOutlet weak var courseTitleLabel: StepikLabel!
    @IBOutlet weak var courseProgressLabel: StepikLabel!
    @IBOutlet weak var courseProgressProgressView: UIProgressView!

    override var nibName: String {
        return "ContinueLearningWidgetView"
    }

    override func setupSubviews() {

    }

}
