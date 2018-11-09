//
// Created by Ivan Magda on 11/7/18.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoTabInfoSkeletonView {
    struct Appearance {
    }
}

final class CourseInfoTabInfoSkeletonView: UIView {
    private let appearance: Appearance

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
}

extension CourseInfoTabInfoSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
    }

    func addSubviews() {
    }

    func makeConstraints() {
    }
}
