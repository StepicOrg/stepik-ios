//
//  NumberQuizViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 26.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import SnapKit
import UIKit

final class NumberQuizViewController: QuizViewController {
    var textField = UITextField()

    let textFieldHeight = 32

    var dataset: StringDataset?
    var reply: NumberReply?

    // Hack for adaptive mode (ugly layout when child quiz has padding)
    var useSmallPadding: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.containerView.addSubview(textField)

        textField.snp.makeConstraints { make -> Void in
            make.top.equalTo(self.containerView).offset(8)
            make.bottom.equalTo(self.containerView)
            make.height.equalTo(textFieldHeight)
        }

        textField.snp.makeConstraints { make -> Void in
            make.leading.equalTo(containerView.safeAreaLayoutGuide.snp.leading).offset(useSmallPadding ? 8 : 16)
            make.trailing.equalTo(containerView.safeAreaLayoutGuide.snp.trailing).offset(useSmallPadding ? -8 : -16)
        }

        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.keyboardType = UIKeyboardType.numbersAndPunctuation
        textField.textColor = UIColor.stepikPrimaryText

        let tapG = UITapGestureRecognizer(target: self, action: #selector(NumberQuizViewController.tap))
        self.view.addGestureRecognizer(tapG)

        textField.addTarget(self, action: #selector(NumberQuizViewController.textFieldTextDidChange(textField:)), for: UIControl.Event.editingChanged)
    }

    @objc func textFieldTextDidChange(textField: UITextField) {
        switch presenter?.state ?? .nothing {
        case .attempt:
            break
        case .submission:
            presenter?.state = .attempt
        default:
            break
        }
    }

    @objc
    func tap() {
        self.view.endEditing(true)
    }

    override var needsToRefreshAttemptWhenWrong: Bool { false }

    override func display(dataset: Dataset) {
        guard let dataset = dataset as? StringDataset else {
            return
        }

        self.dataset = dataset
        textField.text = ""
        textField.isEnabled = true
    }

    override func display(reply: Reply, withStatus status: SubmissionStatus) {
        guard let reply = reply as? NumberReply else {
            return
        }

        self.reply = reply
        display(reply: reply)
        textField.isEnabled = status != .correct
    }

    override func display(reply: Reply) {
        guard let reply = reply as? NumberReply else {
            return
        }

        textField.text = reply.number
    }

    //Override this in the subclass
    override func getReply() -> Reply? { NumberReply(number: textField.text ?? "") }

    private func presentWrongFormatAlert() {
        let alert = UIAlertController(title: "Wrong number format", message: "Only numbers are allowed", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {
            _ in
        }))

        self.present(alert, animated: true, completion: nil)
    }
}
