//
//  CourseInfoView.swift
//  Stepic
//
//  Created by Ivan Magda on 11/1/18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoView {
    struct Appearance {
        let spacing: CGFloat = 0

        let joinButton: JoinButton

        struct JoinButton {
            let insets = UIEdgeInsets(top: 32, left: 47, bottom: 47, right: 47)
            let height: CGFloat = 47

            let backgroundColor = UIColor(hex: 0x66CC66)
            let font = UIFont.systemFont(ofSize: 14)
            let textColor = UIColor.white
            let cornerRadius: CGFloat = 7
        }
    }
}

final class CourseInfoView: UIView {
    private let appearance: Appearance
    private let viewModel: CourseInfoViewModel

    private lazy var scrollableStackView: ScrollableStackView = {
        let stackView = ScrollableStackView(frame: .zero, orientation: .vertical)
        stackView.showsVerticalScrollIndicator = false
        stackView.showsHorizontalScrollIndicator = false
        stackView.spacing = self.appearance.spacing
        return stackView
    }()

    private lazy var joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = self.appearance.joinButton.backgroundColor
        button.titleLabel?.font = self.appearance.joinButton.font
        button.tintColor = self.appearance.joinButton.textColor
        button.layer.cornerRadius = self.appearance.joinButton.cornerRadius

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
        appearance: Appearance = Appearance(joinButton: .init()),
        viewModel: CourseInfoViewModel
    ) {
        self.appearance = appearance
        self.viewModel = viewModel
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()

        self.addBlocks()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addBlocks() {
        self.viewModel.blocks.forEach { viewModel in
            switch viewModel.type {
            case .instructors:
                guard let instructorsViewModel = viewModel as? CourseInfoInstructorsBlockViewModel else {
                    return
                }

                self.scrollableStackView.addArrangedView(
                    CourseInfoInstructorsBlockView(viewModel: instructorsViewModel)
                )
            default:
                guard let textBlockViewModel = viewModel as? CourseInfoTextBlockViewModel else {
                    return
                }

                self.scrollableStackView.addArrangedView(
                    CourseInfoTextBlockView(
                        appearance: self.getTextBlockAppearance(for: viewModel.type),
                        viewModel: textBlockViewModel
                    )
                )
            }
        }

        let buttonContainer = UIView(frame: .zero)
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        self.joinButton.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.addSubview(self.joinButton)

        self.scrollableStackView.addArrangedView(buttonContainer)
        self.joinButton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.joinButton.height)
            make.leading.top.trailing.bottom.equalToSuperview().inset(self.appearance.joinButton.insets)
        }
    }

    private func getTextBlockAppearance(
        for type: CourseInfoBlockType
    ) -> CourseInfoTextBlockView.Appearance {
        switch type {
        case .author:
            return .init(
                headerViewInsets: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 47),
                messageLabelInsets: UIEdgeInsets(top: 29, left: 47, bottom: 0, right: 47)
            )
        case .about:
            return .init(
                headerViewInsets: UIEdgeInsets(top: 18, left: 20, bottom: 0, right: 47),
                messageLabelInsets: UIEdgeInsets(top: 29, left: 47, bottom: 0, right: 47)
            )
        case .requirements:
            return .init(
                headerViewInsets: UIEdgeInsets(top: 32, left: 20, bottom: 0, right: 47),
                messageLabelInsets: UIEdgeInsets(top: 26, left: 47, bottom: 0, right: 47)
            )
        case .targetAudience:
            return .init(
                headerViewInsets: UIEdgeInsets(top: 37, left: 20, bottom: 0, right: 47),
                messageLabelInsets: UIEdgeInsets(top: 26, left: 47, bottom: 0, right: 47)
            )
        case .timeToComplete:
            return .init(
                headerViewInsets: UIEdgeInsets(top: 37, left: 20, bottom: 0, right: 47),
                messageLabelInsets: UIEdgeInsets(top: 12, left: 47, bottom: 0, right: 47)
            )
        case .language, .certificate:
            return .init(
                headerViewInsets: UIEdgeInsets(top: 37, left: 20, bottom: 0, right: 47),
                messageLabelInsets: UIEdgeInsets(top: 12, left: 47, bottom: 0, right: 47)
            )
        case .certificateDetails:
            return .init(
                headerViewInsets: UIEdgeInsets(top: 43, left: 20, bottom: 0, right: 47),
                messageLabelInsets: UIEdgeInsets(top: 12, left: 47, bottom: 0, right: 47)
            )
        default:
            return .init(
                headerViewInsets: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 47),
                messageLabelInsets: UIEdgeInsets(top: 20, left: 47, bottom: 0, right: 47)
            )
        }
    }

    @objc
    private func joinButtonClicked(sender: UIButton) {
        print(#function)
    }
}

extension CourseInfoView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white

        // TODO: Remove
        self.scrollableStackView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
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
