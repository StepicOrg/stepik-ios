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
    var pinsMap: PinsMapView?

    override func awakeFromNib() {
        super.awakeFromNib()

        pinsMap = PinsMapView()
        guard let pinsMap = pinsMap else {
            return
        }

        mapContainer.setRoundedCorners(cornerRadius: 20, borderWidth: 0.5, borderColor: UIColor(hex: 0xcccccc))
        mapContainer.addSubview(pinsMap)
        pinsMap.alignTop("0", leading: "0", bottom: "0", trailing: "0", toView: mapContainer)
        pinsMap.buildMonths(UserActivity.emptyYearPins)
    }

    override func initWithBlock(block: MenuBlock) {
        super.initWithBlock(block: block)
        if let block = block as? PinsMapExpandableMenuBlock {
            pinsMap?.buildMonths(block.pins)
        }
        titleLabel.text = block.title
    }
}
