//
//  CourseInfoTabInfoView.swift
//  Stepic
//
//  Created by Ivan Magda on 11/1/18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

protocol CourseInfoTabInfoViewDelegate: class {
    func courseInfoTabInfoViewDidTapOnJoin(_ courseInfoTabInfoView: CourseInfoTabInfoView)
}

extension CourseInfoTabInfoView {
    struct Appearance {
        let spacing: CGFloat = 0

        let joinButtonInsets = UIEdgeInsets(top: 32, left: 47, bottom: 47, right: 47)
        let joinButtonHeight: CGFloat = 47
        let joinButtonBackgroundColor = UIColor(hex: 0x66CC66)
        let joinButtonFont = UIFont.systemFont(ofSize: 14)
        let joinButtonTextColor = UIColor.white
        let joinButtonCornerRadius: CGFloat = 7
    }
}

final class CourseInfoTabInfoView: UIView {
    typealias BlockViewBuilder = (CourseInfoTabInfoBlockViewModelProtocol) -> UIView?

    weak var delegate: CourseInfoTabInfoViewDelegate?

    private let appearance: Appearance
    private let blockViewBuilder: BlockViewBuilder

    private lazy var scrollableStackView: ScrollableStackView = {
        let stackView = ScrollableStackView(frame: .zero, orientation: .vertical)
        stackView.showsVerticalScrollIndicator = false
        stackView.showsHorizontalScrollIndicator = false
        stackView.spacing = self.appearance.spacing
        return stackView
    }()

    private lazy var joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = self.appearance.joinButtonBackgroundColor
        button.titleLabel?.font = self.appearance.joinButtonFont
        button.tintColor = self.appearance.joinButtonTextColor
        button.layer.cornerRadius = self.appearance.joinButtonCornerRadius

        button.setTitle(NSLocalizedString("JoinCourse", comment: ""), for: .normal)
        button.addTarget(
            self,
            action: #selector(self.joinButtonClicked(sender:)),
            for: .touchUpInside
        )

        return button
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        delegate: CourseInfoTabInfoViewDelegate? = nil,
        blockViewBuilder: @escaping BlockViewBuilder
    ) {
        self.appearance = appearance
        self.delegate = delegate
        self.blockViewBuilder = blockViewBuilder
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showLoading() {
        self.skeleton.viewBuilder = {
            CourseInfoTabInfoSkeletonView()
        }
        self.skeleton.show()
    }

    func hideLoading() {
        self.skeleton.hide()
    }

    func configure(viewModel: CourseInfoTabInfoViewModel) {
        // TODO: Optimize here
        if !self.scrollableStackView.arrangedSubviews.isEmpty {
            self.scrollableStackView.removeAllArrangedViews()
        }

        viewModel.blocks.forEach { viewModel in
            if let blockView = self.blockViewBuilder(viewModel) {
                blockView.translatesAutoresizingMaskIntoConstraints = false
                self.scrollableStackView.addArrangedView(blockView)
            }
        }

        self.addJoinButton()
    }

    private func addJoinButton() {
        let buttonContainer = UIView()
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        self.joinButton.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.addSubview(self.joinButton)

        self.scrollableStackView.addArrangedView(buttonContainer)
        self.joinButton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.joinButtonHeight)
            make.leading.top.trailing.bottom
                .equalToSuperview()
                .inset(self.appearance.joinButtonInsets)
        }
    }

    @objc
    private func joinButtonClicked(sender: UIButton) {
        self.delegate?.courseInfoTabInfoViewDidTapOnJoin(self)
    }
}

extension CourseInfoTabInfoView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.scrollableStackView)
    }

    func makeConstraints() {
        self.scrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
