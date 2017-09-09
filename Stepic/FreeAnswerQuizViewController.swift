//
//  FreeAnswerQuizViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 26.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class FreeAnswerQuizViewController: QuizViewController {

    let textViewHeight = 64

    var dataset: FreeAnswerDataset?
    var reply: FreeAnswerReply?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.containerView.addSubview(textView)
        textView.alignTop("8", leading: "8", bottom: "0", trailing: "-8", to: self.containerView)
        textView.setRoundedCorners(cornerRadius: 8.0, borderWidth: 0.5, borderColor: UIColor.lightGray)
        textView.textColor = UIColor.mainDarkColor
        
        textView.constrainHeight("\(textViewHeight)")

        textView.font = UIFont.systemFont(ofSize: 16)
        // Do any additional setup after loading the view.
    }

    var textView = UITextView()

    override var correctTitle: String {
        return NSLocalizedString("CorrectFreeResponse", comment: "")
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
        textView.text = ""
        textView.isEditable = true
    }

    override func display(reply: Reply, withStatus status: SubmissionStatus) {
        guard let reply = reply as? FreeAnswerReply else {
            return
        }

        self.reply = reply
        display(reply: reply)
        textView.isEditable = status != .correct
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
            mutableAttributed.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: mutableAttributed.string.characters.count))
            textView.attributedText = mutableAttributed
        } else {
            textView.text = reply.text
        }
    }

    //Override this in the subclass
    override func getReply() -> Reply? {
        if let d = dataset {
            if d.isHTMLEnabled {
                return FreeAnswerReply(text: textView.text.replacingOccurrences(of: "\n", with: "<br>"))
            } else {
                return FreeAnswerReply(text: textView.text)
            }
        }
        return FreeAnswerReply(text: textView.text)
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
