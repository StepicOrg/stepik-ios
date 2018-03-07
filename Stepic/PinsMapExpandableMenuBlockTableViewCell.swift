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
    @IBOutlet weak var arrowButton: UIButton!
    var pinsMap: PinsMapView?

    var bottomTitleConstraint: NSLayoutConstraint?

    var block: PinsMapExpandableMenuBlock?
    var updateTableHeightBlock: (() -> Void)?

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
            self.block = block
            block.isExpanded = true
            pinsMap?.buildMonths(block.pins)
        }
        titleLabel.text = block.title
    }

    @IBAction func arrowButtonPressed(_ sender: UIButton) {
        expandPressed()
    }

    func expandPressed() {
        guard let block = block else {
            return
        }

        block.onExpanded?(!block.isExpanded)
        if block.isExpanded {
            expand(block: block)
        } else {
            shrink(block: block)
        }
        updateTableHeightBlock?()
    }

    func expand(block: PinsMapExpandableMenuBlock) {
        bottomTitleConstraint?.isActive = false
        mapContainer.isHidden = false
        arrowButton.setImage(#imageLiteral(resourceName: "menu_arrow_top"), for: .normal)
    }

    func shrink(block: PinsMapExpandableMenuBlock) {
        if bottomTitleConstraint == nil {
            bottomTitleConstraint = titleLabel.alignBottomEdge(withView: self.contentView, predicate: "-26")
        } else {
            bottomTitleConstraint?.isActive = true
        }
        arrowButton.setImage(#imageLiteral(resourceName: "menu_arrow_bottom"), for: .normal)
        mapContainer.isHidden = true
    }

}
