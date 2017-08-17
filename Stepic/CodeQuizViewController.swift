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

    var dataset: String?
    var reply: CodeReply?

    var limitsLabel: UILabel = UILabel()
    var toolbarView: CodeQuizToolbarView = CodeQuizToolbarView(frame: CGRect.zero)
    var codeTextView: UITextView = UITextView()

    let toolbarHeight: CGFloat = 44
    let limitsLabelHeight: CGFloat = 40

    let languagePicker = CodeLanguagePickerViewController(nibName: "PickerViewController", bundle: nil) as CodeLanguagePickerViewController

    var highlightr: Highlightr!
    let textStorage = CodeAttributedString()
    let size: CodeQuizElementsSize = DeviceInfo.isIPad() ? .big : .small

    let playgroundManager = CodePlaygroundManager()
    var currentCode: String = "" {
        didSet {
            guard let options = step.options else { return }
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

    var language: CodeLanguage = CodeLanguage.unsupported {
        didSet {
            textStorage.language = language.highlightr
            if let limit = step.options?.limit(language: language) {
                setLimits(time: limit.time, memory: limit.memory)
            }

            if let template = step.options?.template(language: language, userGenerated: false) {
                tabSize = playgroundManager.countTabSize(text: template.templateString)
            }

            toolbarView.language = language.displayName

            setupAccessoryView(editable: submissionStatus != .correct)

            if let userTemplate = step.options?.template(language: language, userGenerated: true) {
                codeTextView.text = userTemplate.templateString
                currentCode = userTemplate.templateString
                return
            }
            if let template = step.options?.template(language: language, userGenerated: false) {
                codeTextView.text = template.templateString
                currentCode = template.templateString
                return
            }
        }
    }

    override var submissionAnalyticsParams: [String : Any]? {
        guard let step = step else {
            return nil
        }
        var params: [String: Any]? = ["stepId": step.id, "language": language.rawValue]

        if let course = step.lesson?.unit?.section?.course?.id {
            params?["course"] = course
        }

        return params
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
        codeTextView.constrainHeight("\(size.elements.editor.realSizes.editorHeight)")
    }

    fileprivate func setLimits(time: Double, memory: Double) {

        let attTimeLimit = NSAttributedString(string: "Time limit: ", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)])
        let attMemoryLimit = NSAttributedString(string: "Memory limit: ", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)])
        let attTime = NSAttributedString(string: "\(time) seconds\n", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15)])
        let attMemory = NSAttributedString(string: "\(memory) MB", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15)])

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
        let theme = highlightr.theme!
        theme.setCodeFont(UIFont(name: "Courier", size: size.elements.editor.realSizes.fontSize)!)
        highlightr.theme = theme
        codeTextView.backgroundColor = highlightr.theme.themeBackgroundColor
        setupConstraints()

        toolbarView.delegate = self

        guard let options = step.options else {
            return
        }

        languagePicker.languages = options.languages.map({return $0.displayName}).sorted()

        codeTextView.delegate = self

        submissionPressedBlock = {
            [weak self] in
            self?.codeTextView.resignFirstResponder()
        }
    }

    func hidePicker() {
        languagePicker.removeFromParentViewController()
        languagePicker.view.removeFromSuperview()
        isSubmitButtonHidden = false
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

            guard let selectedLanguage = s.step.options?.languages.filter({$0.displayName == s.languagePicker.selectedData}).first else {
                return
            }

            s.language = selectedLanguage
            AnalyticsReporter.reportEvent(AnalyticsEvents.Code.languageChosen, parameters: ["size": "standard", "language": s.language.rawValue])
            s.hidePicker()
        }
    }

    override func display(dataset: Dataset) {
        guard let dataset = dataset as? String else {
            return
        }

        self.dataset = dataset

        guard let options = step.options else {
            return
        }

        setQuizControls(enabled: true)

        if options.languages.count > 1 {
            showPicker()
        } else {
            language = options.languages[0]
            AnalyticsReporter.reportEvent(AnalyticsEvents.Code.languageChosen, parameters: ["size": "standard", "language": language.rawValue])
        }
    }

    var submissionStatus: SubmissionStatus?

    override func display(reply: Reply, withStatus status: SubmissionStatus) {
        guard let reply = reply as? CodeReply else {
            return
        }

        self.reply = reply
        display(reply: reply)
        self.submissionStatus = status

        if status == .correct {
            setQuizControls(enabled: false)
            setupAccessoryView(editable: false)
        } else {
            setQuizControls(enabled: true)
        }
    }

    override func display(reply: Reply) {
        guard let reply = reply as? CodeReply else {
            return
        }

        language = reply.language
        codeTextView.text = reply.code
        currentCode = reply.code
        hidePicker()
    }

    fileprivate func setQuizControls(enabled: Bool) {
        guard let options = step.options else {
            return
        }

        codeTextView.isEditable = enabled
        toolbarView.resetButton.isEnabled = enabled
        if options.languages.count > 1 {
            toolbarView.languageButton.isEnabled = enabled
        }
    }

    override var needsToRefreshAttemptWhenWrong: Bool {
        return false
    }

    override func getReply() -> Reply? {
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
        guard let options = step.options else {
            return
        }

        if options.languages.count > 1 {
            showPicker()
        }
    }

    func fullscreenPressed() {
        guard let options = step.options else {
            return
        }

        AnalyticsReporter.reportEvent(AnalyticsEvents.Code.fullscreenPressed, parameters: ["size": "standard"])

        let fullscreen = FullscreenCodeQuizViewController(nibName: "FullscreenCodeQuizViewController", bundle: nil)
        fullscreen.options = options
        if submissionStatus == .correct {
            fullscreen.isSolved = true
        }
        fullscreen.language = language
        fullscreen.onDismissBlock = {
            [weak self]
            newLanguage, newText in
            guard let s = self else { return }
            s.language = newLanguage
            s.codeTextView.text = newText
            s.playgroundManager.analyzeAndComplete(textView: s.codeTextView, previousText: s.currentCode, language: s.language, tabSize: s.tabSize, inViewController: s, suggestionsDelegate: s)
            s.currentCode = newText
        }

        present(fullscreen, animated: true, completion: nil)
    }

    func resetPressed() {
        guard let options = step.options else {
            return
        }

        let alert = UIAlertController(title: nil, message: NSLocalizedString("ResetAlertDescription", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Reset", comment: ""), style: .destructive, handler: {
            [weak self]
            _ in
            guard let s = self else { return }

            AnalyticsReporter.reportEvent(AnalyticsEvents.Code.resetPressed, parameters: ["size": "standard"])

            if let userTemplate = options.template(language: s.language, userGenerated: true) {
                CoreDataHelper.instance.deleteFromStore(userTemplate)
            }
            if let template = options.template(language: s.language, userGenerated: false) {
                s.codeTextView.text = template.templateString
                s.currentCode = template.templateString
            }
            CoreDataHelper.instance.save()
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension CodeQuizViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard step.options != nil else {
            return
        }

        playgroundManager.analyzeAndComplete(textView: codeTextView, previousText: currentCode, language: language, tabSize: tabSize, inViewController: self, suggestionsDelegate: self)

        currentCode = textView.text

        CoreDataHelper.instance.save()
    }
}

extension CodeQuizViewController: CodeSuggestionDelegate {
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
