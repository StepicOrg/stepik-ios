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
    
    let toolbarHeight : CGFloat = 44
    let codeTextViewHeight : CGFloat = 180
    let limitsLabelHeight : CGFloat = 40
    
    let languagePicker = CodeLanguagePickerViewController(nibName: "PickerViewController", bundle: nil) as CodeLanguagePickerViewController
    
    var highlightr : Highlightr!
    let textStorage = CodeAttributedString()
    
    var language: String = "" {
        didSet {
            textStorage.language = Languages.highligtrFromStepik[language.lowercased()]
            if let limit = step.options?.limit(language: language) {
                setLimits(time: limit.time, memory: limit.memory)
            }
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
        return toolbarHeight + codeTextViewHeight + limitsLabelHeight + 16
    }
    
    fileprivate func setupConstraints() {
        self.containerView.addSubview(limitsLabel)
        self.containerView.addSubview(toolbarView)
        self.containerView.addSubview(codeTextView)
        limitsLabel.alignTopEdge(with: self.containerView, predicate: "8")
        limitsLabel.alignLeading("8", trailing: "0", to: self.containerView)
        limitsLabel.constrainHeight("\(limitsLabelHeight)")
        toolbarView.constrainTopSpace(to: self.limitsLabel, predicate: "8")
        toolbarView.alignLeading("0", trailing: "0", to: self.containerView)
        toolbarView.constrainBottomSpace(to: self.codeTextView, predicate: "8")
        toolbarView.constrainHeight("\(toolbarHeight)")
        codeTextView.alignLeading("0", trailing: "0", to: self.containerView)
        codeTextView.alignBottomEdge(with: self.containerView, predicate: "0")
        codeTextView.constrainHeight("\(codeTextViewHeight)")
    }
    
    fileprivate func setLimits(time: Double, memory: Double) {
        
        let attTimeLimit = NSAttributedString(string: "Time limit: ", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)])
        let attMemoryLimit = NSAttributedString(string: "Memory limit: ", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)])
        let attTime = NSAttributedString(string: "\(time)\n", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15)])
        let attMemory = NSAttributedString(string: "\(memory)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15)])

        let result = NSMutableAttributedString(attributedString: attTimeLimit)
        result.append(attTime)
        result.append(attMemoryLimit)
        result.append(attMemory)
        limitsLabel.numberOfLines = 2
        limitsLabel.attributedText = result
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
        highlightr.setTheme(to: "Androidstudio")
//        codeTextView.inputAccessoryView = textToolbar
        codeTextView.backgroundColor = highlightr.theme.themeBackgroundColor

        setupConstraints()
        
        toolbarView.delegate = self
        
        guard let options = step.options else {
            return
        }
        
        languagePicker.languages = options.languages
       
//        if submission == nil {
//            showPicker()
//        } else {
//            if language != "" {
//                let l = language
//                language = l
//            }
//        }

        codeTextView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func showPicker() {
        isSubmitButtonHidden = true
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
            s.isSubmitButtonHidden = false
            s.delegate?.needsHeightUpdate(s.heightWithoutQuiz + s.expectedQuizHeight, animated: true, breaksSynchronizationControl: false)

        }
    }
    
    override func updateQuizAfterAttemptUpdate() {
        guard let options = step.options else {
            return
        }
        setQuizControls(enabled: true)
    }
    
    fileprivate func setQuizControls(enabled: Bool) {
        codeTextView.isEditable = enabled
        toolbarView.fullscreenButton.isEnabled = enabled
        toolbarView.resetButton.isEnabled = enabled
        toolbarView.languageButton.isEnabled = enabled
    }
    
    override func updateQuizAfterSubmissionUpdate(reload: Bool = true) {
        if submission?.status == "correct" {
            setQuizControls(enabled: false)
        } else {
            setQuizControls(enabled: true)
        }
        
        guard let reply = submission?.reply as? CodeReply else {
            showPicker()
            return
        }
        
        language = reply.language
        codeTextView.text = reply.code
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
        guard let options = step.options else {
            return
        }
        let fullscreen = FullscreenCodeQuizViewController(nibName: "FullscreenCodeQuizViewController", bundle: nil)
        fullscreen.options = options
        fullscreen.language = language
        fullscreen.onDismissBlock = {
            [weak self]
            newLanguage, newText in
            self?.language = newLanguage
            self?.codeTextView.text = newText
        }
        
        present(fullscreen, animated: true, completion: nil)
    }
    
    func resetPressed() {
        guard let options = step.options else {
            return
        }
        
        if let userTemplate = options.template(language: language, userGenerated: true) {
            CoreDataHelper.instance.deleteFromStore(userTemplate)
        }
        if let template = options.template(language: language, userGenerated: false) {
            codeTextView.text = template.templateString
        }
        CoreDataHelper.instance.save()
    }
}

extension CodeQuizViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let options = step.options else {
            return
        }
        
        if let userTemplate = options.template(language: language, userGenerated: true) {
            userTemplate.templateString = textView.text
        } else {
            let newTemplate = CodeTemplate(language: language, template: textView.text)
            newTemplate.isUserGenerated = true
            options.templates += [newTemplate]
        }
        CoreDataHelper.instance.save()
    }
}
