//
//  FullscreenCodeQuizViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 26.06.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout
import Highlightr
import Presentr
import IQKeyboardManagerSwift

class FullscreenCodeQuizViewController: UIViewController {
    
    @IBOutlet weak var showMoreButton: UIButton!
    @IBOutlet weak var doneItem: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    var codeTextView: UITextView = UITextView()
    
    let size: CodeQuizElementsSize = DeviceInfo.isIPad() ? .big : .small

    var isSolved: Bool = false
    var options: StepOptions!
    var onDismissBlock : ((CodeLanguage, String)->Void)?
    let languagePicker = CodeLanguagePickerViewController(nibName: "PickerViewController", bundle: nil) as CodeLanguagePickerViewController
    
    var highlightr : Highlightr!
    let textStorage = CodeAttributedString()
    
    let playgroundManager = CodePlaygroundManager()
    var currentCode : String = "" {
        didSet {
            if let userTemplate = options.template(language: language, userGenerated: true) {
                userTemplate.templateString = codeTextView.text
            } else {
                let newTemplate = CodeTemplate(language: language, template: codeTextView.text)
                newTemplate.isUserGenerated = true
                options.templates += [newTemplate]
            }
        }
    }
    
    var tabSize: Int = 0
    
    fileprivate func setupAccessoryView(editable: Bool) {
        if editable {
            codeTextView.inputAccessoryView = InputAccessoryBuilder.buildAccessoryView(size: size.elements.toolbar, language: language, tabAction: {
                [weak self] in
                guard let s = self else { return }
                s.playgroundManager.insertAtCurrentPosition(symbols: String(repeating: " ", count: s.tabSize), textView: s.codeTextView)
                }, insertStringAction: {
                    [weak self]
                    symbols in
                    guard let s = self else { return }
                    s.playgroundManager.insertAtCurrentPosition(symbols: symbols, textView: s.codeTextView)
                    s.playgroundManager.analyzeAndComplete(textView: s.codeTextView, previousText: s.currentCode, language: s.language, tabSize: s.tabSize, inViewController: s, suggestionsDelegate: s)
                    s.currentCode = s.codeTextView.text
                }, hideKeyboardAction: {
                    [weak self] in
                    guard let s = self else { return }
                    s.codeTextView.resignFirstResponder()
            })
        } else {
            codeTextView.inputAccessoryView = nil
        }
        codeTextView.reloadInputViews()
    }
    
    var language: CodeLanguage = .unsupported {
        didSet {
            textStorage.language = language.highlightr
            
            if let template = options.template(language: language, userGenerated: false) {
                tabSize = playgroundManager.countTabSize(text: template.templateString)
            }
            
            setupAccessoryView(editable: !isSolved)
            
            if let userTemplate = options.template(language: language, userGenerated: true) {
                codeTextView.text = userTemplate.templateString
                currentCode = userTemplate.templateString
                return
            }
            if let template = options.template(language: language, userGenerated: false) {
                codeTextView.text = template.templateString
                currentCode = template.templateString
                return
            }
        }
    }
    
    fileprivate func setupConstraints() {
        self.view.addSubview(codeTextView)
        codeTextView.alignLeading("0", trailing: "0", to: self.view)
        codeTextView.alignBottomEdge(with: self.view, predicate: "0")
        codeTextView.constrainTopSpace(to: self.toolbar, predicate: "0")
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
        let theme = highlightr.theme!
        theme.setCodeFont(UIFont(name: "Courier", size: size.elements.editor.realSizes.fontSize)!)
        highlightr.theme = theme
        codeTextView.backgroundColor = highlightr.theme.themeBackgroundColor
        
        codeTextView.delegate = self
        setupConstraints()
        
        let l = language
        language = l
        
        languagePicker.languages = options.languages.map({return $0.displayName}).sorted()
        
        toolbar.clipsToBounds = true
        doneItem.title = NSLocalizedString("Done", comment: "")
        
        if isSolved {
            codeTextView.isEditable = false
            showMoreButton.isEnabled = false
        }
        
        configureKeyboardNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.sharedManager().enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.sharedManager().enable = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        doneItem.tintColor = UIColor.white
    }

    fileprivate func configureKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(aNotification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(aNotification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc fileprivate func keyboardWasShown(aNotification: NSNotification) {
        let info = aNotification.userInfo
        let infoNSValue = info![UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let kbSize = infoNSValue.cgRectValue.size
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)
        codeTextView.contentInset = contentInsets
        codeTextView.scrollIndicatorInsets = contentInsets
    }
    
    @objc fileprivate func keyboardWillBeHidden(aNotification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        codeTextView.contentInset = contentInsets
        codeTextView.scrollIndicatorInsets = contentInsets
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func closePressed(_ sender: Any) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Code.exitFullscreen, parameters: ["size": "fullscreen"])
        codeTextView.resignFirstResponder()
        onDismissBlock?(language, codeTextView.text)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func showMorePressed(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Reset", comment: ""), style: .destructive, handler: {
            [weak self]
            action in
            self?.resetCode()
        }))
       
        alert.addAction(UIAlertAction(title: NSLocalizedString("Language", comment: ""), style: .default, handler: {
            [weak self]
            action in
            self?.changeLanguage()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender as? UIView
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    let changeLanguagePresentr : Presentr = {
        let changeLanguagePresentr = Presentr(presentationType: .bottomHalf)
        return changeLanguagePresentr
    }()
    
    func changeLanguage() {
        languagePicker.selectedBlock = {
            [weak self] in
            guard let s = self else { return }
            
            guard let selectedLanguage = s.options?.languages.filter({$0.displayName == s.languagePicker.selectedData}).first else {
                return
            }
            
            s.language = selectedLanguage
            AnalyticsReporter.reportEvent(AnalyticsEvents.Code.languageChosen, parameters: ["size": "fullscreen", "language": s.language.rawValue])
        }
        customPresentViewController(changeLanguagePresentr, viewController: languagePicker, animated: true, completion: nil)
    }
    
    func resetCode() {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Code.resetPressed, parameters: ["size": "fullscreen"])
        if let userTemplate = options.template(language: language, userGenerated: true) {
            CoreDataHelper.instance.deleteFromStore(userTemplate)
        }
        if let template = options.template(language: language, userGenerated: false) {
            codeTextView.text = template.templateString
            currentCode = template.templateString
        }
        CoreDataHelper.instance.save()
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

extension FullscreenCodeQuizViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        playgroundManager.analyzeAndComplete(textView: codeTextView, previousText: currentCode, language: language, tabSize: tabSize, inViewController: self, suggestionsDelegate: self)
        
        currentCode = textView.text
        
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

extension FullscreenCodeQuizViewController: CodeSuggestionDelegate {
    func didSelectSuggestion(suggestion: String, prefix: String) {
        codeTextView.becomeFirstResponder()
        playgroundManager.insertAtCurrentPosition(symbols: suggestion.substring(from: suggestion.index(suggestion.startIndex, offsetBy: prefix.characters.count)), textView: codeTextView)
        playgroundManager.analyzeAndComplete(textView: codeTextView, previousText: currentCode, language: language, tabSize: tabSize, inViewController: self, suggestionsDelegate: self)
        currentCode = codeTextView.text
    }
    
    var suggestionsSize: CodeSuggestionsSize {
        return self.size.elements.suggestions
    }
}

