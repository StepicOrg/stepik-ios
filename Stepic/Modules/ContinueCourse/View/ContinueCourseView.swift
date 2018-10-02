//
//  ContinueCourseContinueCourseView.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit
import SnapKit

protocol ContinueCourseViewDelegate: class {
    func continueCourseContinueButtonDidClick(_ continueCourseView: ContinueCourseView)
}

final class ContinueCourseView: UIView {
    private lazy var lastStepView = ContinueLastStepView(frame: .zero)
    weak var delegate: ContinueCourseViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: ContinueCourseViewModel) {
        self.lastStepView.courseTitle = viewModel.title

        if let progressDescription = viewModel.progress?.description,
           let progressValue = viewModel.progress?.value {
            self.lastStepView.progressText = "\(NSLocalizedString("YourCurrentProgressIs", comment: "")) "
                + "\(progressDescription)"
            self.lastStepView.progress = progressValue
        }
        self.lastStepView.coverImageURL = viewModel.coverImageURL

    }

    func showLoading() {
        self.skeleton.viewBuilder = {
            return ContinueCourseSkeletonView(frame: .zero)
        }
        self.skeleton.show()
    }

    func hideLoading() {
        self.skeleton.hide()
    }
}

extension ContinueCourseView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.lastStepView.onContinueButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.continueCourseContinueButtonDidClick(strongSelf)
        }
    }

    func addSubviews() {
        self.addSubview(self.lastStepView)
    }

    func makeConstraints() {
        self.lastStepView.translatesAutoresizingMaskIntoConstraints = false
        self.lastStepView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
