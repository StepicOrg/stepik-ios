//
//  AchievementTableViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 31.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class AchievementTableViewCell: UITableViewCell {

    static var reuseId = "achievementCell"
    
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var cardPadView: UIView!
    @IBOutlet weak var achievementNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellContentView.layer.cornerRadius = 10
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        drawShadow()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

    }
    
    fileprivate func drawShadow(shouldRedraw: Bool = false) {
        if shouldRedraw {
            cellContentView.layer.shadowPath = UIBezierPath(roundedRect: cellContentView.bounds, cornerRadius: cellContentView.layer.cornerRadius).cgPath
            return
        }
        
        cellContentView.backgroundColor = .clear
        cellContentView.layer.shadowPath = UIBezierPath(roundedRect: cellContentView.bounds, cornerRadius: cellContentView.layer.cornerRadius).cgPath
        cellContentView.layer.shouldRasterize = true
        cellContentView.layer.rasterizationScale = UIScreen.main.scale
        cellContentView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        cellContentView.layer.shadowOpacity = 0.2
        cellContentView.layer.shadowRadius = 2.0
        
        cardPadView.backgroundColor = .white
        cardPadView.clipsToBounds = true
        cardPadView.layer.cornerRadius = cellContentView.layer.cornerRadius
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        drawShadow(shouldRedraw: true)
    }
}
