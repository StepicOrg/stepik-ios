//
//  PinsMapBlockContentView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 28.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class PinsMapBlockContentView: UIView, PinsMapContentView {
    lazy var mapView: PinsMapView = {
        let mapView = PinsMapView() // fromNib initialization

        self.addSubview(mapView)
        mapView.alignTop("0", bottom: "0", toView: self)
        mapView.alignLeading("16", trailing: "-16", toView: self)
        mapView.constrainHeight("166")
        mapView.buildMonths(UserActivity.emptyYearPins)

        return mapView
    }()

    func set(pins: [Int]) {
        mapView.buildMonths(pins)
    }
}
