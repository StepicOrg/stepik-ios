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
    
    @IBOutlet weak var doneItem: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    var codeTextView: UITextView = UITextView()
    
    var options: StepOptions!
    var onDismissBlock : ((String, String)->Void)?
    let languagePicker = CodeLanguagePickerViewController(nibName: "PickerViewController", bundle: nil) as CodeLanguagePickerViewController
    
    var highlightr : Highlightr!
    let textStorage = CodeAttributedString()
    
    var language: String = "" {
        didSet {
            textStorage.language = Languages.highligtrFromStepik[language.lowercased()]
            if let userTemplate = options.template(language: language, userGenerated: true) {
                codeTextView.text = userTemplate.templateString
                return
            }
            if let template = options.template(language: language, userGenerated: false) {
                codeTextView.text = template.templateString
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
        //        codeTextView.inputAccessoryView = textToolbar
        codeTextView.backgroundColor = highlightr.theme.themeBackgroundColor
        
        codeTextView.delegate = self
        setupConstraints()
        
        let l = language
        language = l
        
        languagePicker.languages = options.languages
        
        toolbar.clipsToBounds = true
        doneItem.title = NSLocalizedString("Done", comment: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.sharedManager().enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.sharedManager().enable = true
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
            s.language = s.languagePicker.selectedData
            AnalyticsReporter.reportEvent(AnalyticsEvents.Code.languageChosen, parameters: ["size": "fullscreen", "language": s.language])
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
