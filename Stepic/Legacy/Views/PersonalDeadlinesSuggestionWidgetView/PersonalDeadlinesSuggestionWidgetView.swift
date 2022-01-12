//
//  PersonalDeadlinesSuggestionWidgetView.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class PersonalDeadlinesSuggestionWidgetView: NibInitializableView {
    @IBOutlet weak var textLabel: StepikLabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!

    var noAction: (() -> Void)?
    var yesAction: (() -> Void)?

    override var nibName: String { "PersonalDeadlinesSuggestionWidgetView" }

    override func setupSubviews() {
        self.view.roundAllCorners(radius: 8)
        yesButton.setRoundedCorners(cornerRadius: 8, borderWidth: 1, borderColor: .stepikLightBlue)
        localize()
    }

    func localize() {
        noButton.setTitle(NSLocalizedString("PersonalDeadlineWidgetNoButtonTitle", comment: ""), for: .normal)
        yesButton.setTitle(NSLocalizedString("PersonalDeadlineWidgetYesButtonTitle", comment: ""), for: .normal)
        textLabel.text = NSLocalizedString("PersonalDeadlineWidgetSuggestionText", comment: "")
    }

    @IBAction func noPressed(_ sender: Any) {
        noAction?()
    }

    @IBAction func yesPressed(_ sender: Any) {
        yesAction?()
    }
}
