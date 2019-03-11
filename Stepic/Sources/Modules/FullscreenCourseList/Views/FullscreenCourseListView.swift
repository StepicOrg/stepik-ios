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
        self.backgroundColor = .white
    }

    func attachContentView(_ view: UIView) {
        self.contentView?.removeFromSuperview()

        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()

            if #available(iOS 11.0, *) {
                make.leading.trailing.equalTo(self.safeAreaLayoutGuide)
                make.width.equalTo(self.safeAreaLayoutGuide.snp.width)
            } else {
                make.leading.trailing.equalToSuperview()
                make.width.equalTo(self.snp.width)
            }
        }

        self.contentView = view
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
