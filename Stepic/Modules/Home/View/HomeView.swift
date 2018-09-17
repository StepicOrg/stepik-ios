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
}

extension HomeView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {

    }

    func addSubviews() {

    }

    func makeConstraints() {

    }
}
