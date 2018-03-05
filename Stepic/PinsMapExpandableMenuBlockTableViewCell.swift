//
//  PinsMapExpandableMenuBlockTableViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 05.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class PinsMapExpandableMenuBlockTableViewCell: MenuBlockTableViewCell {
    @IBOutlet weak var titleLabel: StepikLabel!
    @IBOutlet weak var mapContainer: UIView!

    var pinsMap: PinsMapView!

    override func awakeFromNib() {
        super.awakeFromNib()

        let map = PinsMap()

        if let month1 = try? map.buildMonth(year: 2018, month: 1),
           let month2 = try? map.buildMonth(year: 2018, month: 2),
           let month3 = try? map.buildMonth(year: 2018, month: 3, lastDay: Date()) {
            pinsMap = PinsMapView(months: [month1, month2, month3])
        }
        mapContainer.addSubview(pinsMap)
    }

    override func initWithBlock(block: MenuBlock) {
        super.initWithBlock(block: block)
        titleLabel.text = block.title
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pinsMap.frame = mapContainer.bounds
    }
}
