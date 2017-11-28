//
//  UserActivityHomeView.swift
//  Stepic
//
//  Created by Ostrenkiy on 28.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class UserActivityHomeView: NibInitializableView {

    @IBOutlet weak var streakCountLabel: StepikLabel!
    @IBOutlet weak var streakTextLabel: StepikLabel!

    override var nibName: String {
        return "UserActivityHomeView"
    }

    func set(streakCount: Int, shouldSolveToday: Bool) {
        streakCountLabel.text = "\(streakCount)"
        let pluralizedDaysCnt = StringHelper.pluralize(number: streakCount, forms: [NSLocalizedString("days1", comment: ""), NSLocalizedString("days234", comment: ""), NSLocalizedString("days567890", comment: "")])
        var countText: String = String(format: NSLocalizedString("SolveStreaksDaysCount", comment: ""), "\(streakCount)", "\(pluralizedDaysCnt)")
        if shouldSolveToday {
            countText += "\n\(NSLocalizedString("SolveSomethingToday", comment: ""))"
        }
        streakTextLabel.text = countText
    }

    override func setupSubviews() {
    }
}
