//
//  PaddingLabel.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 14.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

protocol ProgrammaticallyInitializableViewProtocol: class {
    func setupView()
    func addSubviews()
    func makeConstraints()
}

extension ProgrammaticallyInitializableViewProtocol where Self: UIView {
    func setupView() {
        // Empty body to make method optional
    }

    func addSubviews() {
        // Empty body to make method optional
    }

    func makeConstraints() {
        // Empty body to make method optional
    }
}
