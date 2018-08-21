//
//  CourseCoverImageView.swift
//  NewCourseLists
//
//  Created by Vladislav Kiryukhin on 14.08.2018.
//  Copyright © 2018 Vladislav Kiryukhin. All rights reserved.
//

import UIKit

extension CourseCoverImageView {
    class Appearance {
        let placeholderImage: UIImage = #imageLiteral(resourceName: "1")
        let cornerRadius: CGFloat = 0
    }
}

final class CourseCoverImageView: UIImageView {
    let appearance: Appearance

    override var image: UIImage? {
        didSet {
            if self.image == nil {
                self.image = self.appearance.placeholderImage
            }
        }
    }

    init(frame: CGRect, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CourseCoverImageView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.image = nil

        self.layer.cornerRadius = self.appearance.cornerRadius
        self.clipsToBounds = true
    }
}