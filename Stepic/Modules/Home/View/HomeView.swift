//
//  HomeHomeView.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 17/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit
import SnapKit

extension HomeView {
    struct Appearance {

    }
}

final class HomeView: UIView {
    let appearance: Appearance

    private lazy var scrollableStackView = ScrollableStackView(frame: .zero)

    init(
        frame: CGRect,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addBlockView(_ view: UIView) {
        self.scrollableStackView.addArrangedView(view)
    }
}

extension HomeView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {

    }

    func makeConstraints() {

    }
}
