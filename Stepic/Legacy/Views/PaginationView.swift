//
//  PaginationView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 02.10.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import SnapKit
import UIKit

extension PaginationView {
    struct Appearance {
        let refreshButtonColor = UIColor.stepikAccent
        let refreshButtonSize = CGSize(width: 44, height: 44)
        let refreshButtonImageSize = CGSize(width: 22, height: 22)
        let refreshButtonImageInsets = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 0)
    }
}

final class PaginationView: UIView {
    let appearance: Appearance

    private lazy var activityIndicatorView = UIActivityIndicatorView(style: .stepikGray)
    private lazy var errorRefreshButton: ImageButton = {
        let button = ImageButton()
        button.image = UIImage(named: "Refresh")?.withRenderingMode(.alwaysTemplate)
        button.imageSize = self.appearance.refreshButtonImageSize
        button.imageInsets = self.appearance.refreshButtonImageInsets
        button.tintColor = self.appearance.refreshButtonColor
        button.addTarget(
            self,
            action: #selector(self.errorRefreshButtonClicked),
            for: .touchUpInside
        )
        return button
    }()

    var onRefreshButtonClick: (() -> Void)?

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setLoading() {
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.isHidden = false
        self.errorRefreshButton.isHidden = true
    }

    func setError() {
        self.activityIndicatorView.stopAnimating()
        self.activityIndicatorView.isHidden = true
        self.errorRefreshButton.isHidden = false
    }

    @objc
    private func errorRefreshButtonClicked() {
        self.onRefreshButtonClick?()
    }
}

extension PaginationView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.activityIndicatorView.isHidden = false
        self.errorRefreshButton.isHidden = true
    }

    func addSubviews() {
        self.addSubview(self.activityIndicatorView)
        self.addSubview(self.errorRefreshButton)
    }

    func makeConstraints() {
        self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        self.errorRefreshButton.translatesAutoresizingMaskIntoConstraints = false
        self.errorRefreshButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(self.appearance.refreshButtonSize)
        }
    }
}
