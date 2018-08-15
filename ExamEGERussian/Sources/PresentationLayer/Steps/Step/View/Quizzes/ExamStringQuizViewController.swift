//
//  ExamStringQuizViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 15/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class ExamStringQuizViewController: StringQuizViewController {
    weak var logoutable: Logoutable?

    override func suggestStreak(streak: Int) {
    }

    override func showRateAlert() {
    }

    override func logout(onClose: (() -> Void)?) {
        logoutable?.logout()
    }
}
