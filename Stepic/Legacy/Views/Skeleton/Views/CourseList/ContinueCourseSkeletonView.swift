//
//  ContinueCourseSkeletonView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 01.10.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import SnapKit
import UIKit

extension ContinueCourseSkeletonView {
    struct Appearance {
        let mainInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        let cornerRadius: CGFloat = 8.0
    }
}

final class ContinueCourseSkeletonView: UIView {
    let appearance: Appearance

    private lazy var largeView = UIView()

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

extension ContinueCourseSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear

        self.largeView.clipsToBounds = true
        self.largeView.layer.cornerRadius = self.appearance.cornerRadius
    }

    func addSubviews() {
        self.addSubview(self.largeView)
    }

    func makeConstraints() {
        self.largeView.translatesAutoresizingMaskIntoConstraints = false
        self.largeView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.mainInsets)
        }
    }
}
