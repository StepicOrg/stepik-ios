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
    private var contentView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func attachContentView(_ view: UIView) {
        self.contentView?.removeFromSuperview()

        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints { make in
            make.width.equalTo(self.snp.width)
            make.top.leading.bottom.trailing.equalToSuperview()
        }

        self.contentView = view
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
