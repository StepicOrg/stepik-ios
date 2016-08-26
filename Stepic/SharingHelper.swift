//
//  SharingHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import TUSafariActivity

class SharingHelper {
    static func getSharingController(link: String) -> UIActivityViewController {
        let activityItemSource = CyrillicURLActivityItemSource(link: link)
        let objectsToShare = [activityItemSource]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [TUSafariActivity()])
        activityVC.excludedActivityTypes = [UIActivityTypeAirDrop]
        return activityVC
    }
}