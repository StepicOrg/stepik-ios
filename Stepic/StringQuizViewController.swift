//
//  StringQuizViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 26.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class StringQuizViewController: QuizViewController {

    var textField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.containerView.addSubview(textField)
        textField.alignTop("8", leading: "16", bottom: "0", trailing: "-16", toView: self.containerView)
        textField.borderStyle = UITextBorderStyle.RoundedRect

        let tapG = UITapGestureRecognizer(target: self, action: "tap")
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
        textField.text = ""
    }
    
    //Override this in subclass
    override func updateQuizAfterSubmissionUpdate(reload reload: Bool = true) {
        if submission?.status == "correct" {
            if let r = submission?.reply as? TextReply {
                textField.text = r.text
            }
            
            textField.enabled = false
        } else {
            textField.enabled = true
        }
//        if reload {
//            textField.text = ""
//        }
    }
    
    //Override this in subclass
    override var expectedQuizHeight : CGFloat {
        return 38
    }

    //Override this in the subclass
    override func getReply() -> Reply {
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
