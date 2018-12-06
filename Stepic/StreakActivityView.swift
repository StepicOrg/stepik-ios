//
//  StreakActivityView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 17.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension StreakActivityView {
    struct Appearance {
        let mainInsets = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
        let iconInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 5)
        let descriptionInsets = UIEdgeInsets(top: 12, left: 22, bottom: 12, right: 10)

        let backgroundColor = UIColor(hex: 0x45b0ff, alpha: 0.08)
        let cornerRadius: CGFloat = 8.0

        let streakIconColor = UIColor.mainDark
        let textColor = UIColor.mainDark
        let streakIconSize = CGSize(width: 10, height: 15)
        let streakDaysFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        let streakDescriptionFont = UIFont.systemFont(ofSize: 16, weight: .light)
    }
}

final class StreakActivityView: UIView {
    let appearance: Appearance

    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.backgroundColor
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.cornerRadius
        return view
    }()

    private lazy var streakIconImageView: UIImageView = {
        let image = UIImage(named: "streak")!.withRenderingMode(.alwaysTemplate)
        let view = UIImageView(image: image, highlightedImage: nil)
        view.tintColor = self.appearance.streakIconColor
        return view
    }()

    private lazy var streakDaysLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.streakDaysFont
        label.textColor = self.appearance.textColor
        return label
    }()

    private lazy var streakDescriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = self.appearance.streakDescriptionFont
        label.textColor = self.appearance.textColor
        return label
    }()

    private lazy var iconStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = self.appearance.iconInsets.right
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        return stackView
    }()

    var message: String? {
        didSet {
            self.streakDescriptionLabel.text = self.message
        }
    }

    var streak: Int? {
        didSet {
            self.streakDaysLabel.text = "\(self.streak ?? 0)"
        }
    }

    override var intrinsicContentSize: CGSize {
        let padding = self.appearance.mainInsets.top
            + self.appearance.mainInsets.bottom
            + self.appearance.descriptionInsets.top
            + self.appearance.descriptionInsets.bottom
        return CGSize(
            width: UIViewNoIntrinsicMetric,
            height: padding + self.streakDescriptionLabel.intrinsicContentSize.height
        )
    }

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }
}

extension StreakActivityView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.backgroundView)
        self.backgroundView.addSubview(self.iconStackView)

        self.iconStackView.addArrangedSubview(self.streakIconImageView)
        self.iconStackView.addArrangedSubview(self.streakDaysLabel)

        self.backgroundView.addSubview(self.streakDescriptionLabel)
    }

    func makeConstraints() {
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.mainInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.mainInsets.right)
            make.top.equalToSuperview().offset(self.appearance.mainInsets.top)
            make.bottom.equalToSuperview().offset(-self.appearance.mainInsets.bottom)
        }

        self.iconStackView.translatesAutoresizingMaskIntoConstraints = false
        self.iconStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.iconInsets.left)
            make.top
                .greaterThanOrEqualToSuperview()
                .offset(self.appearance.descriptionInsets.top)
            make.bottom
                .lessThanOrEqualToSuperview()
                .offset(-self.appearance.descriptionInsets.bottom)
        }

        self.streakIconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.streakIconImageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.streakIconSize)
        }

        self.streakDaysLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        self.streakDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.streakDescriptionLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-self.appearance.descriptionInsets.right)
            make.top.equalToSuperview().offset(self.appearance.descriptionInsets.top)
            make.bottom.equalToSuperview().offset(-self.appearance.descriptionInsets.bottom)
            make.leading
                .equalTo(self.iconStackView.snp.trailing)
                .offset(self.appearance.descriptionInsets.left)
        }
    }
}
