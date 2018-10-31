//
//  CourseInfoView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 17/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

final class CourseInfoView: UIView {
    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView(frame: .zero, orientation: .vertical)
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        return view
    }()

    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.mainDark
        return view
    }()

    private lazy var contentFakeView = UIView()

    init(frame: CGRect, scrollDelegate: UIScrollViewDelegate? = nil) {
        super.init(frame: frame)

        self.scrollableStackView.scrollDelegate = scrollDelegate

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CourseInfoView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white

        self.scrollableStackView
    }

    func addSubviews() {
        self.addSubview(self.scrollableStackView)
        self.scrollableStackView.addArrangedView(self.headerView)
        self.scrollableStackView.addArrangedView(self.contentFakeView)
    }

    func makeConstraints() {
        self.scrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.height.equalTo(240)
        }

        self.contentFakeView.translatesAutoresizingMaskIntoConstraints = false
        self.contentFakeView.snp.makeConstraints { make in
            make.height.equalTo(1200)
        }
    }
}
