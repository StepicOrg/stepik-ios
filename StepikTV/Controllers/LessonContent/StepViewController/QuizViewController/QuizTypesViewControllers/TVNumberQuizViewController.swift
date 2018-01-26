//
//  TVNumberQuizViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 25.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class TVNumberQuizViewController: TVQuizViewController {

    var dataset: String?
    var reply: NumberReply?

    var textField = UITextField(frame: CGRect.zero)
    let textFieldHeight: CGFloat = 79.0

    private let textFieldPlaceholder: String = NSLocalizedString("Answer", comment: "")

    override func viewDidLoad() {
        super.viewDidLoad()

        textField.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        textField.font = UIFont.systemFont(ofSize: 47, weight: UIFontWeightRegular)
        textField.textColor = UIColor.white
        textField.placeholder = textFieldPlaceholder

        // Keyboard settings
        textField.keyboardAppearance = .dark
        textField.keyboardType = .decimalPad

        //textField.widthAnchor.constraint(equalToConstant: 809.0).isActive = true
        textField.heightAnchor.constraint(equalToConstant: textFieldHeight).isActive = true

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
        let alert = UIAlertController(title: "Wrong number format", message: "Only numbers are allowed", preferredStyle: UIAlertControllerStyle.alert)

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

extension TVNumberQuizViewController : UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        guard reason == .committed else { return }
        textFieldDidEndEditing()
    }
}
