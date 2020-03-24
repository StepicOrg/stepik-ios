//
//  PinsMapBlockContentView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 28.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import SnapKit
import UIKit

final class PinsMapBlockContentView: UIView, PinsMapContentView {
    lazy var mapView: PinsMapView = {
        // fromNib initialization
        let mapView = PinsMapView()

        self.addSubview(mapView)

        mapView.snp.makeConstraints { make -> Void in
            make.top.bottom.equalTo(self)
            make.leading.equalTo(self).offset(16)
            make.trailing.equalTo(self).offset(-16)
            make.height.equalTo(166)
        }

        mapView.buildMonths(UserActivity.emptyYearPins)

        return mapView
    }()

    func set(pins: [Int]) {
        self.mapView.buildMonths(pins)
    }
}
