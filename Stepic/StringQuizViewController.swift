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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.containerView.addSubview(textView)
        textView.alignTop("8", leading: "8", bottom: "0", trailing: "-8", toView: self.containerView)
        textView.setRoundedCorners(cornerRadius: 8.0, borderWidth: 0.5, borderColor: UIColor.lightGrayColor())

        textView.font = UIFont.systemFontOfSize(16)

        let tapG = UITapGestureRecognizer(target: self, action: #selector(StringQuizViewController.tap))
        self.view.addGestureRecognizer(tapG)
    }
    
    func tap() {
        self.view.endEditing(true)
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
        if let r = submission?.reply as? TextReply {
            textView.text = r.text
        }
        if submission?.status == "correct" {
            textView.editable = false
        } else {
            textView.editable = true
        }
    }
    
    //Override this in subclass
    override var expectedQuizHeight : CGFloat {
        return 72
    }

    //Override this in the subclass
    override func getReply() -> Reply {
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
