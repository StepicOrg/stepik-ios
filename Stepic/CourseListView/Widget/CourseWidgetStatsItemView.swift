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
        var iconSpacing: CGFloat = 3.0
        var imageViewSize = CGSize(width: 12, height: 12)
        var imageTintColor = UIColor.black

        var font = UIFont.systemFont(ofSize: 16, weight: .light)
        var textColor = UIColor.white
    }
}

final class CourseWidgetStatsItemView: UIView {
    let appearance: Appearance

    lazy var imageView: UIImageView = UIImageView()

    private lazy var textLabel: CourseWidgetLabel = {
        var appearance = CourseWidgetLabel.Appearance()
        appearance.font = self.appearance.font
        appearance.textColor = self.appearance.textColor
        appearance.maxLinesCount = 1
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

    init(frame: CGRect, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CourseWidgetStatsItemView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.tintColor = self.appearance.imageTintColor
    }

    func addSubviews() {
        self.addSubview(self.textLabel)
        self.addSubview(self.imageView)
    }

    func makeConstraints() {
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().priority(999)
        }

        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.leading
                .equalToSuperview()
                .priority(999)
            make.centerY
                .equalTo(self.textLabel.snp.centerY)
                .priority(999)
            make.size
                .equalTo(self.appearance.imageViewSize)
                .priority(999)
            make.trailing
                .equalTo(self.textLabel.snp.leading)
                .offset(-self.appearance.iconSpacing)
                .priority(999)
        }
    }
}
