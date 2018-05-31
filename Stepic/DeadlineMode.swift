//
//  DeadlineMode.swift
//  Stepic
//
//  Created by Ostrenkiy on 15.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct DeadlineModeInfo {
    var title: String
    var weeklyLoadHours: Int
    var image: UIImage

    init(title: String, weeklyLoadHours: Int, image: UIImage) {
        self.title = title
        self.weeklyLoadHours = weeklyLoadHours
        self.image = image
    }

    var dailyLoadSeconds: Int {
        return weeklyLoadHours * 60 * 60 / 7
    }
}

enum DeadlineMode {
    case hobby, standard, extreme

    func getModeInfo() -> DeadlineModeInfo {
        switch self {
        case .hobby:
            return DeadlineModeInfo(title: NSLocalizedString("HobbyDeadlineMode", comment: ""), weeklyLoadHours: 3, image: #imageLiteral(resourceName: "25-science-growth-sprout"))
        case .standard:
            return DeadlineModeInfo(title: NSLocalizedString("StandardDeadlineMode", comment: ""), weeklyLoadHours: 7, image: #imageLiteral(resourceName: "27-science-study-learn-graduate"))
        case .extreme:
            return DeadlineModeInfo(title: NSLocalizedString("ExtremeDeadlineMode", comment: ""), weeklyLoadHours: 15, image: #imageLiteral(resourceName: "1-science-rocket-spaceship-rocket-launch"))
        }
    }
}
