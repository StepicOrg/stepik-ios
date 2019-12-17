//
//  FullHeightTableView.swift
//  Stepic
//
//  Created by Ostrenkiy on 25.07.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

final class FullHeightTableView: UITableView {
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: self.contentSize.height)
    }

    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }

    override func beginUpdates() {
        super.beginUpdates()
        self.invalidateIntrinsicContentSize()
    }

    override func endUpdates() {
        super.endUpdates()
        self.invalidateIntrinsicContentSize()
    }
}
