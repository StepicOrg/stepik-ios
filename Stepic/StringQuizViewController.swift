//
//  StringQuizViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 26.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SnapKit

class StringQuizViewController: QuizViewController {

    var textView = IQTextView()

    var dataset: String?
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

        if #available(iOS 11.0, *) {
            textView.snp.makeConstraints { make -> Void in
                make.leading.equalTo(containerView.safeAreaLayoutGuide.snp.leading).offset(useSmallPadding ? 8 : 16)
                make.trailing.equalTo(containerView.safeAreaLayoutGuide.snp.trailing).offset(useSmallPadding ? -8 : -16)
            }
        } else {
            textView.snp.makeConstraints { make -> Void in
                make.leading.equalTo(containerView).offset(useSmallPadding ? 8 : 16)
                make.trailing.equalTo(containerView).offset(useSmallPadding ? -8 : -16)
            }
        }

        textView.setRoundedCorners(cornerRadius: 8.0, borderWidth: 0.5, borderColor: UIColor.lightGray)

        textView.font = UIFont.systemFont(ofSize: 16)
        textView.snp.makeConstraints { $0.height.equalTo(textViewHeight) }
        textView.textColor = UIColor.mainText

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
        guard let dataset = dataset as? String else {
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var needsToRefreshAttemptWhenWrong: Bool {
        return false
    }

    //Override this in the subclass
    override func getReply() -> Reply? {
        return TextReply(text: textView.text ?? "")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension StringQuizViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textViewTextDidChange(textView: textView)
    }
}
