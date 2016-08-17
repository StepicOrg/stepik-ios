//
//  SharingHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class SharingHelper {
    static func getSharingController(link: String) -> UIActivityViewController {
        let objectsToShare = [link]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        return activityVC
    }
}