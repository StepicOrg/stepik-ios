//
//  CourseInfoTabSyllabusSectionView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 19/11/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoTabSyllabusSectionView {
    struct Appearance {
        let backgroundColor = UIColor(hex: 0xf6f6f6)

        let indexTextColor = UIColor.mainDark
        let indexFont = UIFont.systemFont(ofSize: 15)
        let indexLabelInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 12)
        // Width for two-digit indexes
        let indexLabelWidth: CGFloat = 16

        let examTextColor = UIColor.mainDark
        let examFont = UIFont.systemFont(ofSize: 14, weight: .light)

        let textStackViewSpacing: CGFloat = 10
        let textStackViewInsets = UIEdgeInsets(top: 19, left: 12, bottom: 0, right: 15)

        let titleTextColor = UIColor.mainDark
        let titleFont = UIFont.systemFont(ofSize: 14)

        let downloadButtonInsets = UIEdgeInsets(top: 18, left: 0, bottom: 0, right: 16)
        let downloadButtonSize = CGSize(width: 22, height: 22)

        let deadlinesInsets = UIEdgeInsets(top: 16, left: 0, bottom: 19, right: 0)

        let progressViewHeight: CGFloat = 3
        let progressViewMainColor = UIColor.stepicGreen
        let progressViewSecondaryColor = UIColor.clear
    }
}

final class CourseInfoTabSyllabusSectionView: UIView {
    let appearance: Appearance

    private lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.indexFont
        label.textAlignment = .center
        label.textColor = self.appearance.indexTextColor
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleTextColor
        label.numberOfLines = 2
        return label
    }()

    private lazy var downloadButton: DownloadControlView = {
        let view = DownloadControlView(initialState: .readyToDownloading)
        view.isHidden = true
        view.addTarget(self, action: #selector(self.downloadButtonClicked), for: .touchUpInside)
        return view
    }()

    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.textStackViewSpacing
        return stackView
    }()

    private lazy var examLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.examFont
        label.textColor = self.appearance.examTextColor
        label.numberOfLines = 1
        label.text = NSLocalizedString("ExamTitle", comment: "")
        return label
    }()

    private lazy var progressIndicatorView: UIProgressView = {
        let view = UIProgressView()
        view.progressViewStyle = .bar
        view.trackTintColor = self.appearance.progressViewSecondaryColor
        view.progressTintColor = self.appearance.progressViewMainColor
        view.transform = CGAffineTransform(rotationAngle: .pi / -2)
        return view
    }()

    // To use rotated view w/ auto-layout
    private lazy var progressIndicatorViewContainerView = UIView()

    private lazy var deadlinesView: CourseInfoTabSyllabusSectionDeadlinesView = {
        let appearance = CourseInfoTabSyllabusSectionDeadlinesView.Appearance(
            verticalHorizontalOffset: self.appearance.indexLabelInsets.left
                + self.appearance.indexLabelWidth
                + self.appearance.textStackViewInsets.left
        )
        let view = CourseInfoTabSyllabusSectionDeadlinesView(appearance: appearance)
        return view
    }()

    var onDownloadButtonClick: (() -> Void)?

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: CourseInfoTabSyllabusSectionViewModel) {
        self.titleLabel.text = viewModel.title
        self.indexLabel.text = viewModel.index
        self.progressIndicatorView.progress = viewModel.progress

        self.examLabel.isHidden = !viewModel.isExam

        self.updateDownloadState(newState: viewModel.downloadState)

        if let deadlines = viewModel.deadlines {
            self.deadlinesView.isHidden = false
            self.deadlinesView.snp.makeConstraints { make in
                make.top
                    .greaterThanOrEqualTo(self.downloadButton.snp.bottom)
                    .offset(self.appearance.deadlinesInsets.top)
                make.top
                    .greaterThanOrEqualTo(self.textStackView.snp.bottom)
                    .offset(self.appearance.deadlinesInsets.top)
            }

            self.deadlinesView.configure(
                items: deadlines.timelineItems.map { item in
                    .init(
                        text: item.title,
                        progressBefore: item.lineFillingProgress,
                        isCompleted: item.isPointFilled
                    )
                }
            )
        } else {
            self.deadlinesView.isHidden = true
            self.textStackView.snp.makeConstraints { make in
                make.bottom
                    .equalToSuperview()
                    .offset(-self.appearance.deadlinesInsets.bottom)
                    .priority(.medium)
            }
        }
    }

    func updateDownloadState(newState: CourseInfoTabSyllabus.DownloadState) {
        switch newState {
        case .notAvailable:
            self.downloadButton.isHidden = true
        case .available(let isCached):
            self.downloadButton.isHidden = false
            self.downloadButton.actionState = isCached ? .readyToRemoving : .readyToDownloading
        case .waiting:
            self.downloadButton.isHidden = false
            self.downloadButton.actionState = .pending
        case .downloading(let progress):
            self.downloadButton.isHidden = false
            self.downloadButton.actionState = .downloading(progress: progress)
        }
    }

    @objc
    private func downloadButtonClicked() {
        self.onDownloadButtonClick?()
    }
}

extension CourseInfoTabSyllabusSectionView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.indexLabel)

        self.textStackView.addArrangedSubview(self.titleLabel)
        self.textStackView.addArrangedSubview(self.examLabel)
        self.addSubview(self.textStackView)

        self.addSubview(self.downloadButton)
        self.addSubview(self.deadlinesView)

        self.addSubview(self.progressIndicatorViewContainerView)
        self.progressIndicatorViewContainerView.addSubview(self.progressIndicatorView)
    }

    func makeConstraints() {
        self.progressIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.progressIndicatorView.snp.makeConstraints { make in
            make.width.equalTo(self.progressIndicatorViewContainerView.snp.height)
            make.height.equalTo(self.appearance.progressViewHeight)
            make.centerY.centerX.equalToSuperview()
        }

        self.progressIndicatorViewContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.progressIndicatorViewContainerView.snp.makeConstraints { make in
            make.leading.height.bottom.equalToSuperview()
            make.width.equalTo(self.progressIndicatorView.snp.height)
        }

        self.indexLabel.translatesAutoresizingMaskIntoConstraints = false
        self.indexLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.indexLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.titleLabel.snp.centerY)
            make.leading.equalToSuperview().offset(self.appearance.indexLabelInsets.left)
            make.width.equalTo(self.appearance.indexLabelWidth)
        }

        self.downloadButton.translatesAutoresizingMaskIntoConstraints = false
        self.downloadButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.downloadButton.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.downloadButtonSize)
            make.trailing.equalToSuperview().offset(-self.appearance.downloadButtonInsets.right)
            make.centerY.equalTo(self.textStackView.snp.centerY)
        }

        self.textStackView.translatesAutoresizingMaskIntoConstraints = false
        self.textStackView.setContentCompressionResistancePriority(.required, for: .vertical)
        self.textStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.textStackViewInsets.top)
            make.leading
                .equalTo(self.indexLabel.snp.trailing)
                .offset(self.appearance.textStackViewInsets.left)
            make.trailing
                .equalTo(self.downloadButton.snp.leading)
                .offset(-self.appearance.textStackViewInsets.right)
        }

        self.deadlinesView.translatesAutoresizingMaskIntoConstraints = false
        self.deadlinesView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom
                .equalToSuperview()
                .offset(-self.appearance.deadlinesInsets.bottom)
                .priority(.medium)
        }
    }
}
