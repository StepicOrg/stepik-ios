//
//  NumberQuizViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 26.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class NumberQuizViewController: QuizViewController {

    var textField = UITextField()

    let textFieldHeight = 32

    var dataset: String?
    var reply: NumberReply?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.containerView.addSubview(textField)
        textField.alignTop("8", leading: "16", bottom: "0", trailing: "-16", to: self.containerView)
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.keyboardType = UIKeyboardType.numbersAndPunctuation
        textField.constrainHeight("\(textFieldHeight)")
        textField.textColor = UIColor.mainText

        let tapG = UITapGestureRecognizer(target: self, action: #selector(NumberQuizViewController.tap))
        self.view.addGestureRecognizer(tapG)

        textField.addTarget(self, action: #selector(NumberQuizViewController.textFieldTextDidChange(textField:)), for: UIControlEvents.editingChanged)
    }

    func textFieldTextDidChange(textField: UITextField) {
        switch presenter?.state ?? .nothing {
        case .attempt:
            break
        case .submission:
            presenter?.state = .attempt
        default:
            break
        }
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
