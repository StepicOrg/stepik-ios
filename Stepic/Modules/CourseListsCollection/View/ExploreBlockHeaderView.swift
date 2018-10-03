//
//  ExploreBlockHeaderView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 03.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

protocol ExploreBlockHeaderViewProtocol: class {
    var onShowAllButtonClick: (() -> Void)? { get set }
    var titleText: String? { get set }
    var summaryText: String? { get set }
}

extension ExploreBlockHeaderView {
    struct Appearance {
        var titleLabelColor = UIColor(hex: 0x535366)
        let titleLabelFont = UIFont.systemFont(ofSize: 20)
        let titleLabelInsets = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)

        let descriptionLabelFont = UIFont.systemFont(ofSize: 16)
        let descriptionLabelColor = UIColor(hex: 0x535366, alpha: 0.3)

        var showAllButtonColor = UIColor(hex: 0x535366, alpha: 0.3)
        let showAllButtonFont = UIFont.systemFont(ofSize: 20)
        let showAllButtonInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
}

final class ExploreBlockHeaderView: UIView, ExploreBlockHeaderViewProtocol {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.descriptionLabelFont
        label.textColor = self.appearance.descriptionLabelColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var showAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("ShowAll", comment: ""), for: .normal)
        button.tintColor = self.appearance.showAllButtonColor
        button.titleLabel?.font = self.appearance.showAllButtonFont
        button.contentHorizontalAlignment = .right
        button.addTarget(self, action: #selector(self.showAllButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = self.appearance.titleLabelInsets.bottom
        return stackView
    }()

    var titleText: String? {
        didSet {
            self.titleLabel.isHidden = self.titleText == nil
            self.titleLabel.text = self.titleText
        }
    }

    var summaryText: String? {
        didSet {
            self.descriptionLabel.isHidden = self.summaryText == nil
            self.descriptionLabel.text = self.summaryText
        }
    }

    var shouldShowShowAllButton: Bool = true {
        didSet {
            self.showAllButton.isHidden = !self.shouldShowShowAllButton
        }
    }

    var onShowAllButtonClick: (() -> Void)?

    override var intrinsicContentSize: CGSize {
        let labelsStackViewIntrinsicContentSize = self.labelsStackView
            .systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        return CGSize(
            width: UIViewNoIntrinsicMetric,
            height: labelsStackViewIntrinsicContentSize.height
        )
    }

    init(frame: CGRect, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Button selector

    @objc
    private func showAllButtonClicked() {
        self.onShowAllButtonClick?()
    }
}

extension ExploreBlockHeaderView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.labelsStackView)
        self.labelsStackView.addArrangedSubview(self.titleLabel)
        self.labelsStackView.addArrangedSubview(self.descriptionLabel)

        self.addSubview(self.showAllButton)
    }

    func makeConstraints() {
        self.labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.labelsStackView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
        }

        self.showAllButton.translatesAutoresizingMaskIntoConstraints = false
        self.showAllButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.leading
                .equalTo(self.labelsStackView.snp.trailing)
                .offset(self.appearance.showAllButtonInsets.left)
            make.centerY.equalTo(self.titleLabel.snp.centerY)
        }
    }
}
