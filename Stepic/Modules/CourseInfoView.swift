//
//  CourseInfoView.swift
//  Stepic
//
//  Created by Ivan Magda on 11/1/18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoView {
    struct Appearance {
        let spacing: CGFloat = 12.0
    }
}

final class CourseInfoView: UIView {
    typealias ViewFactory = (CourseInfoBlockViewModelProtocol) -> UIView?

    private let appearance: Appearance
    private let viewModel: CourseInfoViewModel
    private let viewFactory: ViewFactory

    private lazy var scrollableStackView: ScrollableStackView = {
        let stackView = ScrollableStackView(frame: .zero, orientation: .vertical)
        stackView.showsVerticalScrollIndicator = false
        stackView.showsHorizontalScrollIndicator = false
        stackView.spacing = self.appearance.spacing
        return stackView
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        viewModel: CourseInfoViewModel,
        viewFactory: @escaping ViewFactory
    ) {
        self.appearance = appearance
        self.viewModel = viewModel
        self.viewFactory = viewFactory
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()

        self.addBlocks()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addBlocks() {
        self.viewModel.blocks.compactMap { viewModel in
            self.viewFactory(viewModel)
        }.forEach { view in
            self.scrollableStackView.addArrangedView(view)
        }
    }
}

extension CourseInfoView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white

        // TODO: Remove
        self.scrollableStackView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }

    func addSubviews() {
        self.addSubview(self.scrollableStackView)
    }

    func makeConstraints() {
        self.scrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
