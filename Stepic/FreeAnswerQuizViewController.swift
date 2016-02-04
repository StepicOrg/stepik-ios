//
//  FreeAnswerQuizViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 26.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class FreeAnswerQuizViewController: QuizViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.containerView.addSubview(textView)
        textView.alignTop("8", leading: "16", bottom: "0", trailing: "-16", toView: self.containerView)
        textView.setRoundedCorners(cornerRadius: 8.0, borderWidth: 1, borderColor: UIColor.grayColor())
        // Do any additional setup after loading the view.
    }

    var textView = UITextView()
    
    override var correctTitle : String {
        return NSLocalizedString("CorrectFreeResponse", comment: "")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var needsToRefreshAttemptWhenWrong : Bool {
        return false
    }
    
    //Override this in subclass
    override func updateQuizAfterAttemptUpdate() {
        textView.text = ""
    }
    
    //Override this in subclass
    override func updateQuizAfterSubmissionUpdate(reload reload: Bool = true) {
        if let r = submission?.reply as? FreeAnswerReply {
            let attributed = try! NSAttributedString(data: (r.text as NSString).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, options: [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType], documentAttributes: nil)
            let mutableAttributed = NSMutableAttributedString(attributedString: attributed)
            mutableAttributed.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(12), range: NSMakeRange(0, mutableAttributed.string.characters.count))
            textView.attributedText = mutableAttributed
        }
        if submission?.status == "correct" {
            textView.editable = false
        } else {
            textView.editable = true
        }
        //        if reload {
        //            textField.text = ""
        //        }
    }
    
    //Override this in subclass
    override var expectedQuizHeight : CGFloat {
        return 80
    }
    
    //Override this in the subclass
    override func getReply() -> Reply {
        return FreeAnswerReply(text: textView.text ?? "")
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
