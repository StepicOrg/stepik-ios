//
//  ProfileDescriptionContentView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 27.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class ProfileDescriptionContentView: UIView, ProfileDescriptionView {
    @IBOutlet weak var shortBioTextLabel: StepikLabel!
    @IBOutlet weak var infoHeaderLabel: StepikLabel!
    @IBOutlet weak var infoTextLabel: StepikLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.infoHeaderLabel.text = NSLocalizedString("Info", comment: "")
    }

    func set(shortBio: String?, info: String?) {
        self.shortBioTextLabel.setTextWithHTMLString(shortBio ?? "")
        self.infoTextLabel.setTextWithHTMLString(info ?? "")
    }
}
