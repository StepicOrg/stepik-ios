//
//  SQLQuizViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 17.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Highlightr
import FLKAutoLayout

class SQLQuizViewController: CodeQuizViewController {

    override var needsToRefreshAttemptWhenWrong: Bool {
        return true
    }

    override func viewDidLoad() {
        limitsLabelHeight = 20
        super.viewDidLoad()
        limitsLabel.text = NSLocalizedString("EnterSQLQuery", comment: "")
        limitsLabel.font = UIFont.boldSystemFont(ofSize: 15)

        toolbarView.languageButton.isEnabled = false
    }

    override func display(dataset: Dataset) {
        guard let dataset = dataset as? String else {
            return
        }

        self.dataset = dataset
        self.submissionStatus = nil

        setQuizControls(enabled: true)
        language = .sql
    }

    override func display(reply: Reply, withStatus status: SubmissionStatus) {
        guard let reply = reply as? SQLReply else {
            return
        }

        self.reply = reply
        self.submissionStatus = status
        display(reply: reply)

        if status == .correct {
            setQuizControls(enabled: false)
            setupAccessoryView(editable: false)
        } else {
            setQuizControls(enabled: true)
        }
    }

    override func display(reply: Reply) {
        guard let reply = reply as? SQLReply else {
            return
        }

        codeTextView.text = reply.code
        currentCode = reply.code
    }

    override func getReply() -> Reply? {
        guard let code = codeTextView.text else {
            return nil
        }
        return SQLReply(code: code)
    }

    fileprivate func setQuizControls(enabled: Bool) {
        codeTextView.isEditable = enabled
        toolbarView.resetButton.isEnabled = enabled
    }
}
