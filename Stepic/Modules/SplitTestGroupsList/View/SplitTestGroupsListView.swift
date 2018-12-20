//
//  SplitTestGroupsListSplitTestGroupsListView.swift
//  stepik-ios
//
//  Created by Ivan Magda on 20/12/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit
import SnapKit

extension SplitTestGroupsListView {
    struct Appearance {

    }
}

final class SplitTestGroupsListView: UIView {
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

extension SplitTestGroupsListView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {

    }

    func makeConstraints() {

    }
}
