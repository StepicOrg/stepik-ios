//
//  CourseListCollectionViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 20.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class CourseListCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var widgetView: CourseWidgetView = CourseWidgetView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: CourseWidgetViewModel, colorMode: CourseWidgetColorMode) {
        self.widgetView.configure(viewModel: viewModel)
        self.widgetView.colorMode = colorMode
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