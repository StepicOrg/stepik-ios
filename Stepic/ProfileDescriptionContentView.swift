//
//  ProfileDescriptionContentView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 27.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class ProfileDescriptionContentView: UIView, ProfileDescriptionView {
    @IBOutlet weak var shortBioTextLabel: StepikLabel!
    @IBOutlet weak var infoHeaderLabel: StepikLabel!
    @IBOutlet weak var infoTextLabel: StepikLabel!

    func set(shortBio: String?, info: String?) {
        shortBioTextLabel.setTextWithHTMLString(shortBio ?? "")
        infoTextLabel.setTextWithHTMLString(info ?? "")
    }
}
