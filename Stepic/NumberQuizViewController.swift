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
        textField.alignTop("8", leading: "16", bottom: "0", trailing: "-16", to: self.containerView)
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.keyboardType = UIKeyboardType.numbersAndPunctuation
        textField.constrainHeight("32")
        
        let tapG = UITapGestureRecognizer(target: self, action: #selector(NumberQuizViewController.tap))
        self.view.addGestureRecognizer(tapG)
        
        textField.addTarget(self, action: #selector(NumberQuizViewController.textFieldTextDidChange(textField:)), for: UIControlEvents.editingChanged)
    }
    
    func textFieldTextDidChange(textField: UITextField) {
        if submission != nil {
            submission = nil
        }
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
        if let r = submission?.reply as? NumberReply {
            textField.text = r.number
        }
        if submission?.status == "correct" {
            textField.isEnabled = false
        } else {
            textField.isEnabled = true
        }
    }
        
    //Override this in the subclass
    override func getReply() -> Reply {
        return NumberReply(number: textField.text ?? "")
    }
    
    fileprivate func presentWrongFormatAlert() {
        let alert = UIAlertController(title: "Wrong number format", message: "Only numbers are allowed", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            action in
            
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
