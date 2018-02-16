//
//  AdaptiveCourseTableViewCell.swift
//  Adaptive 1838
//
//  Created by Vladislav Kiryukhin on 06.02.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

protocol AdaptiveCourseTableViewCellDelegate: class {
    func buttonDidClick(_ cell: AdaptiveCourseTableViewCell)
}

class AdaptiveCourseTableViewCell: UITableViewCell {
    static let reuseId = "AdaptiveCourseTableViewCell"

    weak var delegate: AdaptiveCourseTableViewCellDelegate?

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var studentsCountLabel: UILabel!
    @IBOutlet weak var pointsCountLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var levelLabel: UILabel!

    var gradient: CAGradientLayer?

    override func awakeFromNib() {
        super.awakeFromNib()

        shadowView.backgroundColor = .clear
        shadowView.layer.shouldRasterize = true
        shadowView.layer.rasterizationScale = UIScreen.main.scale
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 1)
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 2.5
    }

    func setData(imageLink: URL?, name: String, description: String, learners: Int, points: Int, level: Int) {
        titleLabel.text = name
        descriptionLabel.text = description
        studentsCountLabel.text = "\(learners)"
        pointsCountLabel.text = "\(points)"
        levelLabel.text = "\(level)"
    }

    func updateColors(firstColor: UIColor, secondColor: UIColor) {
        self.gradient?.removeFromSuperlayer()

        let gradient = CAGradientLayer(colors: [firstColor, secondColor], rotationAngle: 45)
        colorView.layer.addSublayer(gradient)
        self.gradient = gradient
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        shadowView.layoutIfNeeded()
        colorView.setNeedsLayout()
        colorView.layoutIfNeeded()
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 10).cgPath

        gradient?.frame = colorView.bounds
    }

    @IBAction func onLearnButtonClick(_ sender: Any) {
        delegate?.buttonDidClick(self)
    }
}
