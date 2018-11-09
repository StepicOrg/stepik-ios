//
//  CourseInfoTabInfoView.swift
//  Stepic
//
//  Created by Ivan Magda on 11/1/18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoTabInfoView {
    struct Appearance {
        let spacing: CGFloat = 0

        let introVideoHeight: CGFloat = 203

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

final class CourseInfoTabInfoView: UIView {
    private let appearance: Appearance
    private let viewModel: CourseInfoTabInfoViewModel

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

    private lazy var introVideoImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "new-coursepics-python-xl"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(joinButton: .init()),
        viewModel: CourseInfoTabInfoViewModel
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
            switch viewModel.blockType {
            case .introVideo:
                guard let introVideoViewModel = viewModel as? CourseInfoTabInfoIntroVideoBlockViewModel,
                      let _ = URL(string: introVideoViewModel.introURL) else {
                    return
                }

                self.introVideoImageView.translatesAutoresizingMaskIntoConstraints = false
                self.scrollableStackView.addArrangedView(self.introVideoImageView)
                self.introVideoImageView.snp.makeConstraints { make in
                    make.height.equalTo(self.appearance.introVideoHeight)
                }
            case .instructors:
                guard let instructorsViewModel = viewModel as? CourseInfoTabInfoInstructorsBlockViewModel else {
                    return
                }

                self.scrollableStackView.addArrangedView(
                    CourseInfoTabInfoInstructorsBlockView(viewModel: instructorsViewModel)
                )
            default:
                guard let textBlockViewModel = viewModel as? CourseInfoTabInfoTextBlockViewModel else {
                    return
                }

                self.scrollableStackView.addArrangedView(
                    CourseInfoTabInfoTextBlockView(
                        appearance: self.getTextBlockAppearance(for: viewModel.blockType),
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
        for type: CourseInfoTabInfoBlockType
    ) -> CourseInfoTabInfoTextBlockView.Appearance {
        switch type {
        case .author:
            return .init(
                headerViewInsets: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 47),
                messageLabelInsets: UIEdgeInsets(top: 20, left: 47, bottom: 0, right: 47)
            )
        case .about:
            return .init(
                headerViewInsets: UIEdgeInsets(top: 18, left: 20, bottom: 0, right: 47),
                messageLabelInsets: UIEdgeInsets(top: 20, left: 47, bottom: 0, right: 47)
            )
        case .requirements:
            return .init(
                headerViewInsets: UIEdgeInsets(top: 32, left: 20, bottom: 0, right: 47),
                messageLabelInsets: UIEdgeInsets(top: 17, left: 47, bottom: 0, right: 47)
            )
        case .targetAudience:
            return .init(
                headerViewInsets: UIEdgeInsets(top: 37, left: 20, bottom: 0, right: 47),
                messageLabelInsets: UIEdgeInsets(top: 17, left: 47, bottom: 0, right: 47)
            )
        case .timeToComplete, .language, .certificate:
            return .init(
                headerViewInsets: UIEdgeInsets(top: 37, left: 20, bottom: 0, right: 47),
                messageLabelInsets: UIEdgeInsets(top: 3, left: 47, bottom: 0, right: 47)
            )
        case .certificateDetails:
            return .init(
                headerViewInsets: UIEdgeInsets(top: 43, left: 20, bottom: 0, right: 47),
                messageLabelInsets: UIEdgeInsets(top: 3, left: 47, bottom: 0, right: 47)
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

extension CourseInfoTabInfoView: ProgrammaticallyInitializableViewProtocol {
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
