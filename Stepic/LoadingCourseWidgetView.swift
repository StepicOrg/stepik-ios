//
//  LoadingCourseWidgetView.swift
//  Stepic
//
//  Created by Ostrenkiy on 15.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import FLKAutoLayout

class LoadingCourseWidgetView: NibInitializableView {

    @IBOutlet weak var loadingImageView: UIView!
    @IBOutlet weak var loadingTitleView: UIView!
    @IBOutlet weak var loadingStatsView: UIView!
    @IBOutlet weak var loadingButtonView: UIView!

    override var nibName: String {
        return "LoadingCourseWidgetView"
    }

    var gradientImageView: UIImageView?
    private let gradientWidth: CGFloat = 40
    private var isAnimating: Bool = false

    private func setupGradient() {
        gradientImageView = UIImageView(image: #imageLiteral(resourceName: "loading_view_gradient"))
        guard let gradientImageView = gradientImageView else {
            return
        }
        self.view.addSubview(gradientImageView)
        gradientImageView.frame = CGRect(x: 0, y: 0, width: self.gradientWidth, height: self.view.frame.height)
        self.view.layoutSubviews()
    }

    func animateGradient() {
        self.gradientImageView?.frame = CGRect(x: 0, y: 0, width: self.gradientWidth, height: self.view.frame.height)
        UIView.animate(withDuration: 3.0, delay: 0, options: UIViewAnimationOptions.repeat, animations: {
            self.gradientImageView?.frame = CGRect(x: self.view.frame.width, y: 0, width: self.gradientWidth, height: self.view.frame.height)
        })
    }

    override func setupSubviews() {
        loadingImageView.setRoundedCorners(cornerRadius: 8)
        loadingImageView.backgroundColor = UIColor.mainLight
        loadingTitleView.setRoundedCorners(cornerRadius: 8)
        loadingTitleView.backgroundColor = UIColor.mainLight
        loadingStatsView.setRoundedCorners(cornerRadius: 8)
        loadingStatsView.backgroundColor = UIColor.mainLight
        loadingButtonView.setRoundedCorners(cornerRadius: 8)
        loadingButtonView.backgroundColor = UIColor.mainLight
        setupGradient()
        self.layoutSubviews()
        self.view.layoutSubviews()
    }

}
