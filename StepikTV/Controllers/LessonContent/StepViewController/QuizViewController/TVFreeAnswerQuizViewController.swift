//
//  TVFreeAnswerQuizViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 24.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class TVFreeAnswerQuizViewController: TVQuizViewController {

    let textViewHeight = 64

    var dataset: FreeAnswerDataset?
    var reply: FreeAnswerReply?

    var textField = UITextField(frame: CGRect.zero)

    override func viewDidLoad() {
        super.viewDidLoad()

        textField.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        textField.font = UIFont.systemFont(ofSize: 47, weight: UIFontWeightRegular)
        textField.textColor = UIColor.white
        textField.placeholder = "Ответ"

        // Keyboard settings
        textField.keyboardAppearance = .dark

        //textField.widthAnchor.constraint(equalToConstant: 809.0).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 79.0).isActive = true

        textField.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(textField)
        textField.align(to: containerView, top: 10.0, leading: 15.0, bottom: 10.0, trailing: 15.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var needsToRefreshAttemptWhenWrong: Bool {
        return false
    }

    override func display(dataset: Dataset) {
        guard let dataset = dataset as? FreeAnswerDataset else {
            return
        }

        self.dataset = dataset
        textField.text = ""
        textField.isEnabled = true
    }

    override func display(reply: Reply, withStatus status: SubmissionStatus) {
        guard let reply = reply as? FreeAnswerReply else {
            return
        }

        self.reply = reply
        display(reply: reply)
        textField.isEnabled = status != .correct
    }

    override func display(reply: Reply) {
        guard let reply = reply as? FreeAnswerReply else {
            return
        }

        guard let dataset = dataset else {
            return
        }

        if dataset.isHTMLEnabled {
            let attributed = try! NSAttributedString(data: (reply.text as NSString).data(using: String.Encoding.unicode.rawValue, allowLossyConversion: false)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
            let mutableAttributed = NSMutableAttributedString(attributedString: attributed)
            mutableAttributed.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: mutableAttributed.string.count))
            textField.attributedText = mutableAttributed
        } else {
            textField.text = reply.text
        }
    }

    //Override this in the subclass
    override func getReply() -> Reply? {
        if let d = dataset {
            if d.isHTMLEnabled {
                return FreeAnswerReply(text: (textField.text ?? "").replacingOccurrences(of: "\n", with: "<br>"))
            } else {
                return FreeAnswerReply(text: textField.text ?? "")
            }
        }
        return FreeAnswerReply(text: textField.text ?? "")
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
