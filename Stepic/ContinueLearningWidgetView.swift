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

    private var continueLearningAction: (() -> Void)?

    override var nibName: String {
        return "ContinueLearningWidgetView"
    }

    override func setupSubviews() {
        courseImageImageView.setRoundedCorners(cornerRadius: 4)
        continueLearningButton.setTitleColor(UIColor.mainDark, for: .normal)
        continueLearningButton.backgroundColor = UIColor.mainLight
        continueLearningButton.setRoundedCorners(cornerRadius: continueLearningButton.frame.height / 2)
        courseProgressLabel.colorMode = .light
        courseTitleLabel.colorMode = .light
    }

    func setup(widgetData: ContinueLearningWidgetData) {
        let url = URL(string: widgetData.imageURL)
        self.courseImageImageView.setImageWithURL(url: url, placeholder: Images.lessonPlaceholderImage.size50x50)
        self.courseTitleLabel.text = widgetData.title
        if let progress = widgetData.progress {
            self.courseProgressProgressView.progress = progress / 100
            self.courseProgressLabel.text = "Your current progress is \(Int(progress))%"
        }
        continueLearningAction = widgetData.continueLearningAction
    }

    @IBAction func continueLearningPressed(_ sender: UIButton) {
        continueLearningAction?()
    }

}
