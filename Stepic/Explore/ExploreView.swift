//
//  ExploreView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 03.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

final class ExploreView: UIView {
    private lazy var headerView: ExploreBlockHeaderView = {
        let view = ExploreBlockHeaderView(frame: .zero)
        view.backgroundColor = .red
        view.title = "Recommendations"
        view.summary = nil
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .white
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func initialize() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(50)
            make.right.equalToSuperview().offset(-20)
        }
    }
}
