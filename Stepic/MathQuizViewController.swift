//
//  MathQuizViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 26.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class MathQuizViewController: QuizViewController {

    var textField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.containerView.addSubview(textField)
        textField.alignTop("8", leading: "16", bottom: "0", trailing: "-16", to: self.containerView)
        textField.borderStyle = UITextBorderStyle.roundedRect
        
        let tapG = UITapGestureRecognizer(target: self, action: #selector(MathQuizViewController.tap))
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
    override func updateQuizAfterSubmissionUpdate(reload: Bool = true) {
        if let r = submission?.reply as? MathReply {
            textField.text = r.formula
        }
        if submission?.status == "correct" {            
            textField.isEnabled = false
        } else {
            textField.isEnabled = true
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
        return MathReply(formula: textField.text ?? "")
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
