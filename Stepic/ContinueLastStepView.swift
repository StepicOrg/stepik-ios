//
//  ContinueLastStepView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 17.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension ContinueLastStepView {
    struct Appearance {
        let mainInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let contentInsets = UIEdgeInsets(top: 35, left: 19, bottom: 16, right: 19)
        let cornerRadius: CGFloat = 8.0

        let progressHeight: CGFloat = 3.0
        let backgroundOverlayViewColor = UIColor.mainDark.withAlphaComponent(0.85)
    }
}

final class ContinueLastStepView: UIView {
    let appearance: Appearance

    private lazy var continueButton = UIButton()

    // Contains [continue button] and [info]
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    // Contains [course name] and [progress label]
    private lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    // Contains [cover] and [labels]
    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()

    private lazy var courseNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Architectural details in the mode"
        return label
    }()

    private lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.text = "Your progress now 68%"
        return label
    }()

    private lazy var coverImageView: CourseCoverImageView = {
        let view = CourseCoverImageView(frame: .zero)
        return view
    }()

    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.progress = 0.7
        return view
    }()

    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.backgroundOverlayViewColor
        return view
    }()

    private lazy var backgroundImageView = UIImageView()

    init(frame: CGRect, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ContinueLastStepView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.labelsStackView.addArrangedSubview(self.courseNameLabel)
        self.labelsStackView.addArrangedSubview(self.progressLabel)

        self.infoStackView.addArrangedSubview(self.coverImageView)
        self.infoStackView.addArrangedSubview(self.labelsStackView)

        self.contentStackView.addArrangedSubview(self.continueButton)
        self.contentStackView.addArrangedSubview(self.infoStackView)

        self.addSubview(self.backgroundImageView)
        self.addSubview(self.overlayView)

        self.overlayView.addSubview(self.contentStackView)
        self.overlayView.addSubview(self.progressView)
    }

    func makeConstraints() {
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView.snp.makeConstraints { make in
            make.center.equalTo(self.overlayView)
            make.size.equalTo(self.overlayView)
        }

        self.overlayView.translatesAutoresizingMaskIntoConstraints = false
        self.overlayView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.mainInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.mainInsets.right)
            make.top.equalToSuperview().offset(self.appearance.mainInsets.top)
            make.bottom.equalToSuperview().offset(-self.appearance.mainInsets.bottom)
        }

        self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.contentInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.contentInsets.right)
            make.top.equalToSuperview().offset(self.appearance.contentInsets.top)
            make.bottom.equalToSuperview().offset(-self.appearance.contentInsets.bottom)
        }

        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        self.progressView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(self.appearance.progressHeight)
        }
    }
}
