//
//  CodeQuizViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 22.06.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout
import Highlightr

class CodeQuizViewController: QuizViewController {

    var limitsLabel: UILabel = UILabel()
    var toolbarView: CodeQuizToolbarView = CodeQuizToolbarView(frame: CGRect.zero)
    var codeTextView: UITextView = UITextView()
    
    let toolbarHeight : CGFloat = 40
    let codeTextViewHeight : CGFloat = 180
    let limitsLabelHeight : CGFloat = 40
    
    let languagePicker = CodeLanguagePickerViewController(nibName: "PickerViewController", bundle: nil) as CodeLanguagePickerViewController
    
    var highlightr : Highlightr!
    let textStorage = CodeAttributedString()
    
    var language: String = "" {
        didSet {
            textStorage.language = Languages.highligtrFromStepik[language.lowercased()]
            if let userTemplate = step.options?.template(language: language, userGenerated: true) {
                codeTextView.text = userTemplate.templateString
                return
            }
            if let template = step.options?.template(language: language, userGenerated: false) {
                codeTextView.text = template.templateString
                return
            }
        }
    }
    
    override var expectedQuizHeight : CGFloat {
        return toolbarHeight + codeTextViewHeight + limitsLabelHeight + 8
    }
    
    fileprivate func setupConstraints() {
        self.containerView.addSubview(limitsLabel)
        self.containerView.addSubview(toolbarView)
        self.containerView.addSubview(codeTextView)
        limitsLabel.alignTopEdge(with: self.containerView, predicate: "0")
        limitsLabel.alignLeading("0", trailing: "0", to: self.containerView)
        limitsLabel.constrainHeight("\(limitsLabelHeight)")
        toolbarView.constrainTopSpace(to: self.limitsLabel, predicate: "8")
        toolbarView.alignLeading("0", trailing: "0", to: self.containerView)
        toolbarView.constrainBottomSpace(to: self.codeTextView, predicate: "8")
        toolbarView.constrainHeight("\(toolbarHeight)")
        codeTextView.alignLeading("0", trailing: "0", to: self.containerView)
        codeTextView.alignBottomEdge(with: self.containerView, predicate: "0")
        codeTextView.constrainHeight("\(codeTextViewHeight)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer()
        layoutManager.addTextContainer(textContainer)
        codeTextView = UITextView(frame: CGRect.zero, textContainer: textContainer)
        codeTextView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        codeTextView.autocorrectionType = UITextAutocorrectionType.no
        codeTextView.autocapitalizationType = UITextAutocapitalizationType.none
        codeTextView.textColor = UIColor(white: 0.8, alpha: 1.0)
        highlightr = textStorage.highlightr
        highlightr.setTheme(to: "Dracula")
//        codeTextView.inputAccessoryView = textToolbar
        codeTextView.backgroundColor = highlightr.theme.themeBackgroundColor


        setupConstraints()
        
        toolbarView.delegate = self
        
        guard let options = step.options else {
            return
        }
        
        languagePicker.languages = options.languages
       
        showPicker()

        // Do any additional setup after loading the view.
    }
    
    func showPicker() {
        addChildViewController(languagePicker)
        view.addSubview(languagePicker.view)
        languagePicker.view.align(to: containerView)
        languagePicker.backButton.isHidden = true
        languagePicker.selectedBlock = {
            [weak self] in
            guard let s = self else { return }
            s.language = s.languagePicker.selectedData
            s.languagePicker.removeFromParentViewController()
            s.languagePicker.view.removeFromSuperview()
        }
    }
    
    override func updateQuizAfterAttemptUpdate() {
        guard let options = step.options else {
            return
        }
    }
    
    override func updateQuizAfterSubmissionUpdate(reload: Bool = true) {
        
    }
    
    override var needsToRefreshAttemptWhenWrong : Bool {
        return false
    }
    
    override func getReply() -> Reply {
        return CodeReply(code: codeTextView.text ?? "", language: language)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CodeQuizViewController : CodeQuizToolbarDelegate {
    func changeLanguagePressed() {
        showPicker()
    }
    
    func fullscreenPressed() {
        
    }
}
