//
//  TVLoadingView.swift
//  StepikTV
//
//  Created by Александр Пономарев on 30.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class TVLoadingView: UIView {

    private var blurStyle = UIBlurEffectStyle.regular
    private var colorStyle: UIColor = UIColor.black

    private var blurEffectView: UIVisualEffectView!
    private var vibrancyEffectView: UIVisualEffectView!

    private var activityIndicator: UIActivityIndicatorView!
    private var titleLabel: UILabel!

    init(frame: CGRect, color: UIColor) {
        super.init(frame: frame)

        colorStyle = color
        addSubviews()
        setupLayout()
    }

    init(frame: CGRect, style: UIBlurEffectStyle, color: UIColor) {
        super.init(frame: frame)

        blurStyle = style
        colorStyle = color
        addEffectSubviews()
        addSubviews()
        setupLayout()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addEffectSubviews()
        addSubviews()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addEffectSubviews()
        addSubviews()
        setupLayout()
    }

    func setup(title: String? = nil) {
        titleLabel.text = title
        activityIndicator.startAnimating()
    }

    func purge() {
        activityIndicator.stopAnimating()
        self.isHidden = true
    }

    private func addEffectSubviews() {
        // Init blur
        let blurEffect = UIBlurEffect(style: blurStyle)

        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds

        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)

        self.insertSubview(vibrancyEffectView, at: 0)
        self.insertSubview(blurEffectView, at: 0)
    }

    private func addSubviews() {
        // Init objects
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.color = colorStyle

        titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.systemFont(ofSize: 38.0, weight: UIFontWeightMedium)
        titleLabel.textColor = colorStyle

        self.addSubview(activityIndicator)
        self.addSubview(titleLabel)
    }

    private func setupLayout() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicator.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 22.0).isActive = true

        titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -50).isActive = true
    }

}
