//
//  CourseWidgetStatsItemView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 14.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseWidgetStatsItemView {
    struct Appearance {
        let iconSpacing: CGFloat = 3.0
        var imageViewSize = CGSize(width: 12, height: 12)

        let font = UIFont.systemFont(ofSize: 16, weight: .light)
    }
}

final class CourseWidgetStatsItemView: UIView {
    let appearance: Appearance

    lazy var imageView: UIImageView = UIImageView()

    private lazy var textLabel: CourseWidgetLabel = {
        let appearance = CourseWidgetLabel.Appearance(font: self.appearance.font)
        let label = CourseWidgetLabel(frame: .zero, appearance: appearance)
        return label
    }()

    var image: UIImage? {
        didSet {
            self.imageView.image = self.image
        }
    }

    var text: String? {
        didSet {
            self.textLabel.text = self.text
        }
    }

    var colorMode: CourseWidgetColorMode {
        didSet {
            self.updateColorMode()
        }
    }

    init(
        frame: CGRect,
        colorMode: CourseWidgetColorMode = .default,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.colorMode = colorMode
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateColorMode() {
        self.textLabel.colorMode = self.colorMode
    }
}

extension CourseWidgetStatsItemView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.imageView.contentMode = .scaleAspectFit
    }

    func addSubviews() {
        self.addSubview(self.textLabel)
        self.addSubview(self.imageView)
    }

    func makeConstraints() {
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
        }

        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalTo(self.textLabel.snp.centerY)
            make.size.equalTo(self.appearance.imageViewSize)
            make.trailing.equalTo(self.textLabel.snp.leading).offset(-self.appearance.iconSpacing)
        }
    }
}
