//
//  ContentLanguageContentLanguageView.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit
import SnapKit

extension ContentLanguageView {
    struct Appearance {

    }
}

final class ContentLanguageView: UIView {
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

extension ContentLanguageView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {

    }

    func addSubviews() {

    }

    func makeConstraints() {

    }
}
