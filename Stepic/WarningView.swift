//
//  WarningView.swift
//  Stepic
//
//  Created by Alexander Karpov on 26.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

class WarningView: NibInitializableView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var tryAgainButton: UIButton!

    var textLabel: StepikLabel!

    weak var delegate: WarningViewDelegate?

    override var nibName: String {
        return "WarningView"
    }

    fileprivate func localize() {
        tryAgainButton.setTitle(NSLocalizedString("TryAgain", comment: ""), for: UIControlState())
    }

    fileprivate func getAttributedDescription(_ text: String) -> NSAttributedString {
        let text = text

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center

        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor: UIColor.lightGray,
            NSAttributedStringKey.paragraphStyle: paragraph]

        return NSAttributedString(string: text, attributes: attributes)
    }

    convenience init(frame: CGRect, delegate: WarningViewDelegate, text: String, image: UIImage, width: CGFloat, fontSize: CGFloat = 14, contentMode: UIViewContentMode = UIViewContentMode.scaleAspectFit) {
        self.init(frame: frame)
        localize()
        self.delegate = delegate
        self.imageView.image = image
        self.imageView.contentMode = contentMode
        textLabel = StepikLabel()
        self.view.insertSubview(textLabel, belowSubview: tryAgainButton)
        textLabel.textAlignment = NSTextAlignment.center
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFont(ofSize: 14)
        textLabel.snp.makeConstraints { make -> Void in
            make.leading.equalTo(view).offset(8)
            make.trailing.equalTo(view).offset(-8)
            make.top.equalTo(centerView).offset(4)
        }
        textLabel.attributedText = getAttributedDescription(text)
        tryAgainButton.snp.makeConstraints { $0.top.equalTo(textLabel).offset(8) }
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    @IBAction func didPressButton(_ sender: AnyObject) {
        delegate?.didPressButton()
    }

}

protocol WarningViewDelegate : class {
    func didPressButton()
}
