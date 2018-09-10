//
//  ScrollableStackView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 10.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

final class ScrollableStackView: UIView {
    private let orientation: Orientation

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = self.orientation.stackViewOrientation
        return stackView
    }()

    private lazy var scrollView = UIScrollView()

    var arrangedViewsCount: Int {
        return self.stackView.arrangedSubviews.count
    }

    init(frame: CGRect, orientation: Orientation = .vertical) {
        self.orientation = orientation
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public interface

    func addArrangedView(_ view: UIView) {
        self.stackView.addArrangedSubview(view)
    }

    func removeArrangedView(_ view: UIView) {
        self.stackView.removeArrangedSubview(view)
    }

    func insertArrangedView(_ view: UIView, at index: Int) {
        self.stackView.insertArrangedSubview(view, at: index)
    }

    enum Orientation {
        case vertical
        case horizontal

        var stackViewOrientation: UILayoutConstraintAxis {
            switch self {
            case .vertical:
                return UILayoutConstraintAxis.vertical
            case .horizontal:
                return UILayoutConstraintAxis.horizontal
            }
        }
    }
}

extension ScrollableStackView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()

            if case .vertical = self.orientation {
                make.width.equalTo(self.scrollView.snp.width)
            } else {
                make.height.equalTo(self.scrollView.snp.height)
            }
        }
    }
}
