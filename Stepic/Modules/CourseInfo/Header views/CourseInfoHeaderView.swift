//
//  CourseInfoHeaderView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 01/11/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoHeaderView {
    struct Appearance {

    }
}

final class CourseInfoHeaderView: UIView {
    let appearance: Appearance

    private lazy var backgroundView = BlurredImageView(frame: .zero)

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

    func loadImage(url: URL?) {
        self.backgroundView.loadImage(url: url)
    }
}

extension CourseInfoHeaderView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
    }

    func addSubviews() {
        self.addSubview(self.backgroundView)
    }

    func makeConstraints() {
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
