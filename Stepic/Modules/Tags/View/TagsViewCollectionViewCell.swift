//
//  TagsViewCollectionViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 11.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension TagsViewCollectionViewCell {
    struct Appearance {
        let backgroundColor = UIColor(hex: 0x535366, alpha: 0.06)
        let backgroundCornerRadius: CGFloat = 20

        let textColor = UIColor.mainText
        let font = UIFont.systemFont(ofSize: 16, weight: .light)
        let labelInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
}

final class TagsViewCollectionViewCell: UICollectionViewCell, Reusable {
    let appearance: Appearance

    private lazy var tagBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.backgroundColor
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.backgroundCornerRadius
        return view
    }()

    private lazy var tagLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.font
        label.textColor = self.appearance.textColor
        label.textAlignment = .center
        return label
    }()

    init(frame: CGRect, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: TagViewModel) {
        self.tagLabel.text = viewModel.title
    }

    func highlight() {
        self.tagBackgroundView.backgroundColor = self.appearance
            .backgroundColor
            .withAlphaComponent(0.5)
    }

    func unhighlight() {
        self.tagBackgroundView.backgroundColor = self.appearance.backgroundColor
    }
}

extension TagsViewCollectionViewCell: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.contentView.addSubview(self.tagBackgroundView)
        self.tagBackgroundView.addSubview(self.tagLabel)
    }

    func makeConstraints() {
        self.tagBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.tagBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.tagLabel.translatesAutoresizingMaskIntoConstraints = false
        self.tagLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.labelInsets)
        }
    }
}
