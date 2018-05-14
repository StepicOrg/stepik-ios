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
    var load: Int
    var image: UIImage

    init(title: String, load: Int, image: UIImage) {
        self.title = title
        self.load = load
        self.image = image
    }
}

enum DeadlineMode {
    case hobby, standard, extreme

    func getMode() -> DeadlineModeInfo {
        switch self {
        case .hobby:
            return DeadlineModeInfo(title: "Hobby", load: 3, image: #imageLiteral(resourceName: "25-science-growth-sprout"))
        case .standard:
            return DeadlineModeInfo(title: "Standard", load: 7, image: #imageLiteral(resourceName: "27-science-study-learn-graduate"))
        case .extreme:
            return DeadlineModeInfo(title: "Extreme", load: 15, image: #imageLiteral(resourceName: "1-science-rocket-spaceship-rocket-launch"))
        }
    }
}
