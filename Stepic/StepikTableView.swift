//
//  StepikTableView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 16.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class StepikTableView: UITableView {

    // Empty state placeholder
    var emptySetPlaceholder: StepikPlaceholder? {
        didSet {
            if let p = emptySetPlaceholder {
                emptySetView?.removeFromSuperview()
                emptySetView = StepikPlaceholderContainer(p).build()
                (emptySetView as? StepikPlaceholderView)?.delegate = self
            }
        }
    }

    // View for empty state
    private var emptySetView: UIView?

    // Trick with removing cell separators: we should store previous footer to restore
    private var savedFooterView: UIView?
}

extension StepikTableView {
    private var hasContent: Bool {
        return (0..<self.numberOfSections).map({ self.numberOfRows(inSection: $0) }).reduce(0, +) > 0
    }

    private func handleEmptySetView(isHidden: Bool) {
        if isHidden {
            tableFooterView = savedFooterView
            emptySetView?.isHidden = true
            return
        }

        updateEmptySetLayout()

        // Remove cell separators
        savedFooterView = self.tableFooterView
        tableFooterView = UIView()

        emptySetView?.isHidden = false
    }

    private func updateEmptySetLayout() {
        guard let emptySetView = emptySetView else {
            return
        }

        if emptySetView.superview == nil {
            emptySetView.translatesAutoresizingMaskIntoConstraints = false

            addSubview(emptySetView)
            emptySetView.alignCenter(withView: self)
            emptySetView.align(toView: self)

            emptySetView.setNeedsLayout()
            emptySetView.layoutIfNeeded()
        }
        bringSubview(toFront: emptySetView)
    }

    override func reloadData() {
        super.reloadData()
        handleEmptySetView(isHidden: hasContent)
    }

    override func endUpdates() {
        super.endUpdates()
        handleEmptySetView(isHidden: hasContent)
    }
}

extension StepikTableView: StepikPlaceholderViewDelegate {
    func buttonDidClick(_ button: UIButton) {
        emptySetPlaceholder?.buttonAction?()
    }
}
