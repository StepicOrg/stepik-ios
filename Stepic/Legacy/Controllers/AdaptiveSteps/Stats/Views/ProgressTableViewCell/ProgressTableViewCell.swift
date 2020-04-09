//
//  ProgressTableViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 27.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

final class ProgressTableViewCell: UITableViewCell {
    static var reuseId = "progressCell"

    @IBOutlet weak var bracketLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var firstDateLabel: UILabel!
    @IBOutlet weak var secondDateLabel: UILabel!
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var xpPerWeekTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.xpPerWeekTitleLabel.text = NSLocalizedString("AdaptiveXPperWeekCell", comment: "")
    }

    func updateInfo(expCount: Int, begin: Date, end: Date, isRecord: Bool = false) {
        self.pointsLabel.text = "\(expCount)" + (isRecord ? " 🎉" : "")

        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none

        self.firstDateLabel.text = formatter.string(from: begin)
        self.secondDateLabel.text = formatter.string(from: end)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.pointsLabel.text = ""
        self.firstDateLabel.text = ""
        self.secondDateLabel.text = ""
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.colorize()
    }

    private func colorize() {
        [
            self.pointsLabel,
            self.xpPerWeekTitleLabel,
            self.firstDateLabel,
            self.secondDateLabel
        ].forEach { $0.textColor = .stepikSystemGray }

        self.bracketLabel.textColor = .stepikAccent
    }
}
