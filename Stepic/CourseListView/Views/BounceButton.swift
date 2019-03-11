//
//  BounceButton.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 14.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class BounceButton: UIButton {
    enum Animation {
        static let bounceDuration: TimeInterval = 0.15
        static let bounceScale: CGFloat = 0.95
    }

    override var isHighlighted: Bool {
        didSet {
            self.bounce()
        }
    }

    private func bounce() {
        UIView.animate(withDuration: Animation.bounceDuration) {
            self.transform = self.isHighlighted
                ? CGAffineTransform(scaleX: Animation.bounceScale, y: Animation.bounceScale)
                : CGAffineTransform(scaleX: 1, y: 1)
        }
    }
}
