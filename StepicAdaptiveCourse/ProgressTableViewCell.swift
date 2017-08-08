//
//  ProgressTableViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 27.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class ProgressTableViewCell: UITableViewCell {
    
    static var reuseId = "progressCell"
    
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var firstDateLabel: UILabel!
    @IBOutlet weak var secondDateLabel: UILabel!
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var cardPadView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellContentView.layer.cornerRadius = 10
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        drawShadow()
    }
    
    func updateInfo(expCount: Int, begin: Date, end: Date, isRecord: Bool = false) {
        pointsLabel.text = "\(expCount)" + (isRecord ? " 🎉" : "")
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        firstDateLabel.text = formatter.string(from: begin)
        secondDateLabel.text = formatter.string(from: end)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        pointsLabel.text = ""
        firstDateLabel.text = ""
        secondDateLabel.text = ""
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
