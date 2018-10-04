//
// Created by Ivan Magda on 2018-10-05.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation

extension CAGradientLayer {
    func applyDefaultLocations() {
        locations = computeDefaultLocations()
    }

    func computeDefaultLocations(_ count: Int? = nil) -> [NSNumber]? {
        guard let countColors = count == nil ? colors?.count : count,
              countColors > 0 else {
            return nil
        }

        let size = 1.0 / Double(countColors - 1)
        var locations = [0.0]

        for i in 1..<countColors {
            locations.append(locations[i - 1] + size)
        }

        return locations as [NSNumber]
    }
}
