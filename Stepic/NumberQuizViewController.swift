//
//  NumberQuizViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 26.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

class NumberQuizViewController: QuizViewController {

    var textField = UITextField()

    let textFieldHeight = 32

    var dataset: String?
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
        textField.textColor = UIColor.mainText

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

    override func display(dataset: Dataset) {
        guard let dataset = dataset as? String else {
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
    override func getReply() -> Reply? {
        return NumberReply(number: textField.text ?? "")
    }

    fileprivate func presentWrongFormatAlert() {
        let alert = UIAlertController(title: "Wrong number format", message: "Only numbers are allowed", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            _ in

        }))

        self.present(alert, animated: true, completion: nil)
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
