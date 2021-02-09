//
//  StringQuizViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 26.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import IQKeyboardManagerSwift
import SnapKit
import UIKit

final class StringQuizViewController: QuizViewController {
    var textView = IQTextView()

    var dataset: StringDataset?
    var reply: TextReply?

    let textViewHeight = 64

    // Hack for adaptive mode (ugly layout when child quiz has padding)
    var useSmallPadding: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.containerView.addSubview(textView)

        textView.snp.makeConstraints { make -> Void in
            make.top.equalTo(self.containerView).offset(8)
            make.bottom.equalTo(self.containerView)
        }

        textView.snp.makeConstraints { make -> Void in
            make.leading.equalTo(containerView.safeAreaLayoutGuide.snp.leading).offset(useSmallPadding ? 8 : 16)
            make.trailing.equalTo(containerView.safeAreaLayoutGuide.snp.trailing).offset(useSmallPadding ? -8 : -16)
        }

        textView.roundAllCorners(radius: 8.0, borderWidth: 0.5, borderColor: UIColor.lightGray)

        textView.font = UIFont.systemFont(ofSize: 16)
        textView.snp.makeConstraints { $0.height.equalTo(textViewHeight) }
        textView.textColor = UIColor.stepikPrimaryText

        let tapG = UITapGestureRecognizer(target: self, action: #selector(StringQuizViewController.tap))
        self.view.addGestureRecognizer(tapG)

        textView.delegate = self
    }

    func textViewTextDidChange(textView: UITextView) {
        switch presenter?.state ?? .nothing {
        case .attempt:
            break
        case .submission:
            presenter?.state = .attempt
        default:
            break
        }
    }

    override func display(dataset: Dataset) {
        guard let dataset = dataset as? StringDataset else {
            return
        }

        self.dataset = dataset
        textView.text = ""
        textView.isEditable = true
    }

    override func display(reply: Reply, withStatus status: SubmissionStatus) {
        guard let reply = reply as? TextReply else {
            return
        }

        self.reply = reply
        display(reply: reply)
        textView.isEditable = status != .correct
    }

    override func display(reply: Reply) {
        guard let reply = reply as? TextReply else {
            return
        }

        textView.text = reply.text
    }

    @objc func tap() {
        self.view.endEditing(true)
    }

    override var needsToRefreshAttemptWhenWrong: Bool { false }

    //Override this in the subclass
    override func getReply() -> Reply? { TextReply(text: textView.text ?? "") }
}

extension StringQuizViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textViewTextDidChange(textView: textView)
    }
}
