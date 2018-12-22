//
//  SplitTestTableViewCell.swift
//  Stepic
//
//  Created by Ivan Magda on 12/22/18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

final class SplitTestTableViewCell: UITableViewCell, Reusable {
    enum Appearance {
        static let textLabelInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }

    private lazy var stepikLabel = StepikLabel()

    var title: String? {
        didSet {
            self.stepikLabel.text = self.title
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        self.addSubview(self.stepikLabel)
        self.stepikLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Appearance.textLabelInsets)
        }
    }
}
