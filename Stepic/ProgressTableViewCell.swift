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

    @IBOutlet weak var bracketLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var firstDateLabel: UILabel!
    @IBOutlet weak var secondDateLabel: UILabel!
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var xpPerWeekTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        colorize()

        xpPerWeekTitleLabel.text = NSLocalizedString("AdaptiveXPperWeekCell", comment: "")
    }

    fileprivate func colorize() {
        bracketLabel.textColor = UIColor.mainDark
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
}
