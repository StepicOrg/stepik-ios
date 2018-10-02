//
//  FullscreenCourseListFullscreenCourseListView.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 19/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit
import SnapKit

final class FullscreenCourseListView: UIView {
    private let contentView: UIView

    init(frame: CGRect, contentView: UIView) {
        self.contentView = contentView
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FullscreenCourseListView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.contentView)
    }

    func makeConstraints() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.snp.makeConstraints { make in
            make.width.equalTo(self.snp.width)
            make.top.leading.bottom.trailing.equalToSuperview()
        }
    }
}
