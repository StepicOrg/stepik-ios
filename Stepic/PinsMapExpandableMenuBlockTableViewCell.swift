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

    var pins: [Int] = [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 4, 0, 0, 0, 0, 41, 1, 12, 10, 1, 1, 1, 7, 4, 13, 3, 11, 8, 20, 0, 4, 0, 6, 5, 20, 26, 9, 1, 1, 4, 0, 0, 1, 22, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0].reversed()
    var pinsMap: PinsMapView!

    override func awakeFromNib() {
        super.awakeFromNib()

        mapContainer.setRoundedCorners(cornerRadius: 20, borderWidth: 0.5, borderColor: UIColor(hex: 0xcccccc))

        pinsMap = PinsMapView()
        mapContainer.addSubview(pinsMap)
        pinsMap.alignTop("0", leading: "0", bottom: "0", trailing: "0", toView: mapContainer)
        pinsMap.buildMonths(pins)
    }

    override func initWithBlock(block: MenuBlock) {
        super.initWithBlock(block: block)
        if let block = block as? PinsMapExpandableMenuBlock {
            pins = block.pins
        }
        titleLabel.text = block.title
    }
}
