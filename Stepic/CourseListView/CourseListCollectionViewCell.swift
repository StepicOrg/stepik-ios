//
//  CourseListCollectionViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 20.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class CourseListCollectionViewCell: UICollectionViewCell, Reusable {
    private let colorMode: CourseListColorMode

    private lazy var widgetView: CourseWidgetView = CourseWidgetView(
        frame: .zero,
        colorMode: self.colorMode
    )

    override init(frame: CGRect) {
        self.colorMode = .default
        super.init(frame: frame)
    }

    init(frame: CGRect, colorMode: CourseListColorMode) {
        self.colorMode = colorMode
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: CourseWidgetViewModel) {
        self.widgetView.configure(viewModel: viewModel)
    }
}

extension CourseListCollectionViewCell: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.contentView.addSubview(self.widgetView)
    }

    func makeConstraints() {
        self.widgetView.translatesAutoresizingMaskIntoConstraints = false
        self.widgetView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
