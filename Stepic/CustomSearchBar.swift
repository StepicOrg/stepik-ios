//
//  CustomSearchBar.swift
//  Stepic
//
//  Created by Ostrenkiy on 13.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import FLKAutoLayout

protocol CustomSearchBarDelegate: class {
    func changedText(in searchBar: CustomSearchBar, to text: String)
    func startedEditing(in searchBar: CustomSearchBar)
    func cancelPressed(in searchBar: CustomSearchBar)
}

class CustomSearchBar: UIView, UITextFieldDelegate {
    var view: UIView!

    weak var delegate: CustomSearchBarDelegate?
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var textField: UITextField!

    @IBOutlet weak var textFieldCancelHorizontalSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButtonWidthConstraint: NSLayoutConstraint!

    let cancelWidth: CGFloat = 70
    let textFieldCancelDistance: CGFloat = 8

    private var isCancelActive: Bool = false

    var barTintColor: UIColor? = UIColor.white {
        didSet {
            backgroundColor = barTintColor
        }
    }

    var text: String = "" {
        didSet {
            textField.text = text
        }
    }

    var mainColor: UIColor? = UIColor.blue {
        didSet {
            cancelButton.setTitleColor(mainColor, for: .normal)
            textField.tintColor = mainColor
        }
    }

    var placeholder: String = NSLocalizedString("Search", comment: "") {
        didSet {
            textField.placeholder = placeholder
        }
    }

    var hasShadowImage: Bool = true {
        didSet {
            shadowView.isHidden = !hasShadowImage
        }
    }

    private lazy var shadowView: UIView = {
        let v = UIView()
        self.view.addSubview(v)
        v.backgroundColor = UIColor.lightGray
        v.alignLeading("0", trailing: "0", to: self.view)
        v.alignBottomEdge(with: self.view, predicate: "0")
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
        glassImage.alignTop("0", leading: "\(horizontalInset)", bottom: "0", trailing: "-\(horizontalInset)", to: v)
        return v
    }()

    private func setupSubviews() {
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

    func cancel() {
        if isCancelActive {
            setCancelButton(visible: false, animated: true)
        }
        textField.resignFirstResponder()
        textField.text = ""
        delegate?.cancelPressed(in: self)
    }

    func textFieldDidChange(textField: UITextField) {
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

    // MARK: Standard View Setup

    private func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        setupSubviews()
    }

    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CustomSearchBar", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        // 1. setup any properties here

        // 2. call super.init(frame:)
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here

        // 2. call super.init(coder:)
        super.init(coder: aDecoder)

        // 3. Setup view from .xib file
        setup()
    }
}
