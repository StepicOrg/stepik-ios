//
//  ExamNumberQuizViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 15/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class ExamNumberQuizViewController: NumberQuizViewController {
    override func suggestStreak(streak: Int) {
    }

    override func showRateAlert() {
    }

    // TODO: Handle logout
    override func logout(onClose: (() -> Void)?) {
        AuthInfo.shared.token = nil
    }
}
