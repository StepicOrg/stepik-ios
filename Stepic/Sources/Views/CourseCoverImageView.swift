//
//  CourseCoverImageView.swift
//  NewCourseLists
//
//  Created by Vladislav Kiryukhin on 14.08.2018.
//  Copyright © 2018 Vladislav Kiryukhin. All rights reserved.
//

import UIKit
import Nuke

extension CourseCoverImageView {
    struct Appearance {
        var placeholderImage: UIImage = #imageLiteral(resourceName: "lesson_cover_50")
        var imageFadeInDuration: TimeInterval = 0.15
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

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadImage(url: URL?) {
        if let url = url {
            Nuke.loadImage(
                with: url,
                options: ImageLoadingOptions(
                    transition: ImageLoadingOptions.Transition.fadeIn(
                        duration: self.appearance.imageFadeInDuration
                    )
                ),
                into: self,
                completion: nil
            )

        } else {
            self.image = nil
        }
    }
}

extension CourseCoverImageView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.image = nil
    }
}
