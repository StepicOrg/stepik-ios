//
//  SharingHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import TUSafariActivity
import UIKit

enum SharingHelper {
    static func getSharingController(_ link: String) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(
            activityItems: [CyrillicURLActivityItemSource(link: link)],
            applicationActivities: [TUSafariActivity()]
        )
        activityViewController.excludedActivityTypes = [.airDrop]
        return activityViewController
    }
}
