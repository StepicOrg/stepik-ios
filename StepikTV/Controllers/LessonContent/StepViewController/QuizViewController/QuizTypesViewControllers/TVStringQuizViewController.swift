//
//  TVStringQuizViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 25.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class TVStringQuizViewController: TVQuizViewController {

    var dataset: String?
    var reply: TextReply?

    var textField = UITextField(frame: CGRect.zero)

    var textFieldHeightConstraint: NSLayoutConstraint!
    let textFieldMinHeight: CGFloat = 158.0
    let textFieldMaxHeight: CGFloat = 316.0

    private let textFieldPlaceholder: String = NSLocalizedString("Answer", comment: "")

    override func viewDidLoad() {
        super.viewDidLoad()

        textField.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        textField.font = UIFont.systemFont(ofSize: 47, weight: UIFontWeightRegular)
        textField.textColor = UIColor.white
        textField.placeholder = textFieldPlaceholder

        // Keyboard settings
        textField.keyboardAppearance = .dark
        textField.keyboardType = .default

        //textField.widthAnchor.constraint(equalToConstant: 809.0).isActive = true
        textFieldHeightConstraint = textField.heightAnchor.constraint(equalToConstant: textFieldMinHeight)
        textFieldHeightConstraint.isActive = true

        textField.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(textField)
        textField.align(to: containerView, top: 10.0, leading: 15.0, bottom: 10.0, trailing: 15.0)
    }

    func textFieldDidEndEditing() {
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
        textField.text = textFieldPlaceholder
        textField.isEnabled = true
    }

    override func display(reply: Reply, withStatus status: SubmissionStatus) {
        guard let reply = reply as? TextReply else {
            return
        }

        self.reply = reply
        display(reply: reply)
        textField.isEnabled = status != .correct
    }

    override func display(reply: Reply) {
        guard let reply = reply as? TextReply else {
            return
        }

        textField.text = reply.text
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
        return TextReply(text: textField.text ?? "")
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

extension TVStringQuizViewController : UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        guard reason == .committed else { return }

        let size = UILabel.heightForLabelWithText(textField.text!, lines: 0, font: textField.font!, width: textField.bounds.width, alignment: .center)

        if size > textFieldMinHeight && size < textFieldMaxHeight { textFieldHeightConstraint.constant = size }

        textFieldDidEndEditing()
    }
}
