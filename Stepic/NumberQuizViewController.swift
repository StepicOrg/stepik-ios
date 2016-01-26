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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.containerView.addSubview(textField)
        textField.alignTop("8", leading: "16", bottom: "0", trailing: "-16", toView: self.containerView)
        textField.borderStyle = UITextBorderStyle.RoundedRect
        textField.keyboardType = UIKeyboardType.DecimalPad
        // Do any additional setup after loading the view.
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
            if let r = submission?.reply as? NumberReply {
                textField.text = r.number
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
        return NumberReply(number: textField.text ?? "")
    }
    
    private func presentWrongFormatAlert() {
        let alert = UIAlertController(title: "Wrong number format", message: "Only numbers are allowed", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
            action in
            
        }))
    }
    
    override func checkReplyReady() -> Bool {
        if (Double(textField.text ?? "") != nil) {
            return true
        } else {
            presentWrongFormatAlert()
            return false
        }
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
