//
//  ExploreExploreView.swift
//  stepik-ios
//
//  Created by Stepik on 10/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit
import SnapKit

protocol BaseExploreViewDelegate: class {
    func refreshControlDidRefresh()
}

final class BaseExploreView: UIView {
    private lazy var scrollableStackView = ScrollableStackView(frame: .zero)
    weak var delegate: BaseExploreViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Blocks

    func addBlockView(_ view: UIView) {
        self.scrollableStackView.addArrangedView(view)
    }

    func removeBlockView(_ view: UIView) {
        self.scrollableStackView.removeArrangedView(view)
    }

    func insertBlockView(_ view: UIView, at position: Int) {
        self.scrollableStackView.insertArrangedView(view, at: position)
    }

    func insertBlockView(_ view: UIView, before previousView: UIView) {
        for (index, subview) in self.scrollableStackView.arrangedSubviews.enumerated()
            where subview === previousView {
            self.scrollableStackView.insertArrangedView(view, at: index)
            return
        }
        self.scrollableStackView.addArrangedView(view)
    }

    // MARK: - Refresh control

    func endRefreshing() {
        self.scrollableStackView.endRefreshing()
    }
}

extension BaseExploreView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white

        self.scrollableStackView.delegate = self
        self.scrollableStackView.isRefreshControlEnabled = true
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

extension BaseExploreView: ScrollableStackViewDelegate {
    func scrollableStackViewRefreshControlDidRefresh(_ scrollableStackView: ScrollableStackView) {
        self.delegate?.refreshControlDidRefresh()
    }
}
