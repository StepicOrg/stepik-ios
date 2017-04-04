//
//  UnitTableViewCell.swift
//  Stepic
//
//  Created by Anton Kondrashov on 24/03/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import SDWebImage

class UnitTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var scoreProgressView: UIProgressView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    class func heightForCellWithUnit(_ unit: Unit) -> CGFloat {
        let defaultTitle = "Ooops, something got wrong"
        let text = "\(unit.position). \(unit.lesson?.title ?? defaultTitle)"
        return 50 + UILabel.heightForLabelWithText(text, lines: 0, standardFontOfSize: 14, width: UIScreen.main.bounds.width - 129)
        
    }
    
    func initWithUnit(_ unit: Unit) {
        let defaultTitle = "Ooops, something got wrong"
        titleLabel.text = "\(unit.position). \(unit.lesson?.title ?? defaultTitle)"
        
        progressView.backgroundColor = UIColor.white
        if let passed = unit.progress?.isPassed {
            if passed {
                progressView.backgroundColor = UIColor.stepicGreenColor()
            }
        }
        
        if let progress = unit.progress {
            if progress.cost == 0 {
                scoreProgressView.isHidden = true
                scoreLabel.isHidden = true
            } else {
                scoreProgressView.progress = Float(progress.score) / Float(progress.cost)
                scoreLabel.text = "\(progress.score)/\(progress.cost)"
            }
        }
        
        
        if !(unit.isActive || unit.section?.testSectionAction != nil) {
            titleLabel.isEnabled = false
            scoreProgressView.isHidden = true
            scoreLabel.isHidden = true
        }
        
        if let coverURL = unit.lesson?.coverURL {
            coverImageView.sd_setImage(with: URL(string: coverURL), placeholderImage: Images.lessonPlaceholderImage.size50x50)
        } else {
            coverImageView.image = Images.lessonPlaceholderImage.size50x50
        }
        
    }
}

