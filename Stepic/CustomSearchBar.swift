//
//  CustomSearchBar.swift
//  Stepic
//
//  Created by Ostrenkiy on 13.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol CustomSearchBarDelegate: class {
    func changedText(in searchBar: CustomSearchBar, to text: String)
    func startedEditing(in searchBar: CustomSearchBar)
    func cancelPressed(in searchBar: CustomSearchBar)
    func returnPressed(in searchBar: CustomSearchBar)
}

@IBDesignable
class CustomSearchBar: NibInitializableView, UITextFieldDelegate {

    weak var delegate: CustomSearchBarDelegate?
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var textField: UITextField!

    @IBOutlet weak var textFieldCancelHorizontalSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButtonWidthConstraint: NSLayoutConstraint!

    let cancelWidth: CGFloat = 70
    let textFieldCancelDistance: CGFloat = 8

    private var isCancelActive: Bool = false

    override var nibName: String {
        return "CustomSearchBar"
    }

    @IBInspectable
    var barTintColor: UIColor? = UIColor.white {
        didSet {
            backgroundColor = barTintColor
        }
    }

    @IBInspectable
    var text: String {
        set(newText) {
            textField.text = newText
        }
        get {
            return textField.text ?? ""
        }
    }

    @IBInspectable
    var mainColor: UIColor? = UIColor.blue {
        didSet {
            cancelButton.setTitleColor(mainColor, for: .normal)
            textField.tintColor = mainColor
        }
    }

    @IBInspectable
    var placeholder: String = NSLocalizedString("Search", comment: "") {
        didSet {
            textField.placeholder = placeholder
        }
    }

    @IBInspectable
    var hasShadowImage: Bool = true {
        didSet {
            shadowView.isHidden = !hasShadowImage
        }
    }

    private lazy var shadowView: UIView = {
        let v = UIView()
        self.view.addSubview(v)
        v.backgroundColor = UIColor.lightGray
        v.alignLeading("0", trailing: "0", toView: self.view)
        v.alignBottomEdge(withView: self.view, predicate: "0")
        v.constrainHeight("0.5")
        return v
    }()

    private lazy var glassView: UIView = {
        let v = UIView()
        let imageSize: Int = 16
        let horizontalInset: Int = 8
        v.constrainWidth("\(imageSize + 2 * horizontalInset)", height: "\(imageSize)")
        let glassImage = UIImageView(image: #imageLiteral(resourceName: "search_glass"))
        glassImage.contentMode = .scaleAspectFit
        v.addSubview(glassImage)
        glassImage.constrainWidth("\(imageSize)", height: "\(imageSize)")
        glassImage.alignTop("0", leading: "\(horizontalInset)", bottom: "0", trailing: "-\(horizontalInset)", toView: v)
        return v
    }()

    override func setupSubviews() {
        textField.placeholder = placeholder
        backgroundColor = barTintColor
        cancelButton.setTitleColor(mainColor, for: .normal)
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        textField.text = text
        hasShadowImage = true

        textField.leftViewMode = .always
        textField.leftView = glassView
        textField.layoutSubviews()
        textField.delegate = self

        cancelButton.addTarget(self, action: #selector(CustomSearchBar.cancel), for: UIControlEvents.touchUpInside)
        textField.addTarget(self, action: #selector(CustomSearchBar.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
    }

    @objc func cancel() {
        if isCancelActive {
            setCancelButton(visible: false, animated: true)
        }
        textField.resignFirstResponder()
        delegate?.cancelPressed(in: self)
        textField.text = ""
    }

    @objc func textFieldDidChange(textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        delegate?.changedText(in: self, to: text)
    }

    private func setCancelButton(visible: Bool, animated: Bool) {
        if visible {
            textFieldCancelHorizontalSpaceConstraint.constant = textFieldCancelDistance
            cancelButtonWidthConstraint.constant = cancelWidth
        } else {
            cancelButtonWidthConstraint.constant = 0
            textFieldCancelHorizontalSpaceConstraint.constant = 0
        }

        isCancelActive = visible

        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                [weak self] in
                self?.view.updateConstraints()
                self?.view.layoutSubviews()
            })
        } else {
            self.view.updateConstraints()
            self.view.layoutSubviews()
        }
    }

    // MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !isCancelActive {
            setCancelButton(visible: true, animated: true)
        }
        delegate?.startedEditing(in: self)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        delegate?.returnPressed(in: self)
        return true
    }
}
