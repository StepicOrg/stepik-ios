//
//  StringQuizViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 26.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class StringQuizViewController: QuizViewController {

    var textView = UITextView()

    var dataset: String?
    var reply: TextReply?

    let textViewHeight = 64

    override func viewDidLoad() {
        super.viewDidLoad()

        self.containerView.addSubview(textView)
        textView.alignTop("8", leading: "8", bottom: "0", trailing: "-8", to: self.containerView)
        textView.setRoundedCorners(cornerRadius: 8.0, borderWidth: 0.5, borderColor: UIColor.lightGray)

        textView.font = UIFont.systemFont(ofSize: 16)
        _ = textView.constrainHeight("\(textViewHeight)")
        textView.textColor = UIColor.mainDarkColor
        
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

    func tap() {
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
