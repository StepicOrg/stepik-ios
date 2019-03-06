//
//  ContentLanguageSwitchContentLanguageSwitchView.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 12/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit
import SnapKit

protocol ContentLanguageSwitchViewDelegate: class {
    func contentLanguageSwitchViewDiDLanguageSelected(
        _ contentLanguageSwitchView: ContentLanguageSwitchView,
        selectedViewModel: ContentLanguageSwitchViewModel
    )
}

extension ContentLanguageSwitchView {
    struct Appearance {
        let headerTitleColor = UIColor(hex: 0x535366, alpha: 0.3)

        let descriptionFont = UIFont.systemFont(ofSize: 14)
        let descriptionTextColor = UIColor.lightGray
        let descriptionLabelInsets = UIEdgeInsets(top: 20, left: 20, bottom: 16, right: 20)

        let buttonsInsets = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
        let buttonSize = CGSize(width: 46, height: 40)
        let buttonsSpacing: CGFloat = 13
        let buttonCornerRadius: CGFloat = 4
    }
}

final class ContentLanguageSwitchView: UIView {
    let appearance: Appearance
    weak var delegate: ContentLanguageSwitchViewDelegate?

    private lazy var containerView: ExploreBlockContainerView = {
        var appearance = ExploreBlockContainerView.Appearance()
        appearance.contentViewInsets = self.appearance.buttonsInsets
        return ExploreBlockContainerView(
            headerView: self.headerView,
            contentView: self.contentView,
            shouldShowSeparator: true,
            appearance: appearance
        )
    }()

    private lazy var headerView: ExploreBlockHeaderView = {
        var appearance = ExploreBlockHeaderView.Appearance()
        appearance.titleLabelColor = self.appearance.headerTitleColor

        let headerView = ExploreBlockHeaderView(appearance: appearance)
        headerView.titleText = NSLocalizedString("ChooseSearchLanguage", comment: "")
        headerView.summaryText = nil
        headerView.shouldShowShowAllButton = false
        return headerView
    }()

    private lazy var contentView = UIView()
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .leading
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = self.appearance.buttonsSpacing
        return stackView
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = self.appearance.descriptionFont
        label.textColor = self.appearance.descriptionTextColor
        label.text = "\(NSLocalizedString("ContentLanguageDescription", comment: ""))" +
            " \(NSLocalizedString("CanBeChangedInSettings", comment: ""))"
        return label
    }()

    private lazy var switchButtons = self.buttonsStackView.arrangedSubviews
        as? [ContentLanguageSwitchButton]
    private var viewModels: [ContentLanguageSwitchViewModel] = []

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModels: [ContentLanguageSwitchViewModel]) {
        self.buttonsStackView.removeAllArrangedSubviews()

        self.viewModels = viewModels
        for (i, viewModel) in viewModels.enumerated() {
            let button = self.makeLanguageButton(title: viewModel.title, tag: i)
            button.isSelected = viewModel.isSelected
            self.buttonsStackView.addArrangedSubview(button)
        }
    }

    private func makeLanguageButton(title: String, tag: Int) -> ContentLanguageSwitchButton {
        let button = ContentLanguageSwitchButton(type: .custom)
        button.layer.cornerRadius = self.appearance.buttonCornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.buttonSize)
        }

        button.setTitle(title, for: .normal)
        button.tag = tag
        button.addTarget(
            self,
            action: #selector(self.languageButtonClicked(_:)),
            for: .touchUpInside
        )
        return button
    }

    @objc
    private func languageButtonClicked(_ sender: ContentLanguageSwitchButton) {
        guard let switchButtons = self.switchButtons else {
            return
        }

        switchButtons.filter { $0.tag == sender.tag }.forEach { $0.isSelected = true }
        switchButtons.filter { $0.tag != sender.tag }.forEach { $0.isSelected = false }

        if let viewModel = self.viewModels[safe: sender.tag] {
            self.delegate?.contentLanguageSwitchViewDiDLanguageSelected(
                self,
                selectedViewModel: viewModel
            )
        }
    }
}

extension ContentLanguageSwitchView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.containerView)
        self.contentView.addSubview(self.buttonsStackView)
        self.contentView.addSubview(self.descriptionLabel)
    }

    func makeConstraints() {
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.buttonsStackView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.height.equalTo(self.appearance.buttonSize.height)
        }

        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-self.appearance.descriptionLabelInsets.bottom)
            make.top
                .equalTo(self.buttonsStackView.snp.bottom)
                .offset(self.appearance.descriptionLabelInsets.top)
            make.leading.trailing.equalToSuperview()
        }
    }
}
