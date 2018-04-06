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
    var emptySetPlaceholder: StepikPlaceholder?

    // Loading state placeholder
    var loadingPlaceholder: StepikPlaceholder?

    // View for placeholders
    lazy private var placeholderView: StepikPlaceholderView = {
        let view = StepikPlaceholderView()
        return view
    }()

    // Trick with removing cell separators: we should store previous footer to restore
    private var savedFooterView: UIView?
    private var hasSavedFooter: Bool = false
}

extension StepikTableView {
    private var hasContent: Bool {
        return (0..<self.numberOfSections).map({ self.numberOfRows(inSection: $0) }).reduce(0, +) > 0
    }

    private func handlePlaceholder(isHidden: Bool) {
        if isHidden {
            if hasSavedFooter {
                tableFooterView = savedFooterView
                savedFooterView = nil
                hasSavedFooter = false
            }
            placeholderView.isHidden = true
            return
        }

        updatePlaceholderLayout()

        // Remove cell separators
        savedFooterView = self.tableFooterView
        hasSavedFooter = true
        
        tableFooterView = UIView()
        placeholderView.isHidden = false
    }

    private func handleEmptySetPlaceholder(isHidden: Bool) {
        if let p = emptySetPlaceholder, !isHidden {
            placeholderView.set(placeholder: p.style)
            placeholderView.delegate = self
        }
        handlePlaceholder(isHidden: isHidden)
    }

    func showLoadingPlaceholder(force: Bool = false) {
        if let p = loadingPlaceholder {
            placeholderView.set(placeholder: p.style)
            placeholderView.delegate = self
        }
        handlePlaceholder(isHidden: !force && hasContent)
    }

    private func updatePlaceholderLayout() {
        if placeholderView.superview == nil {
            placeholderView.translatesAutoresizingMaskIntoConstraints = false

            addSubview(placeholderView)
            placeholderView.alignCenter(withView: self)
            placeholderView.align(toView: self)

            placeholderView.setNeedsLayout()
            placeholderView.layoutIfNeeded()
        }
        bringSubview(toFront: placeholderView)
    }

    override func reloadData() {
        super.reloadData()
        handleEmptySetPlaceholder(isHidden: hasContent)
    }

    override func endUpdates() {
        super.endUpdates()
        handleEmptySetPlaceholder(isHidden: hasContent)
    }
}

extension StepikTableView: StepikPlaceholderViewDelegate {
    func buttonDidClick(_ button: UIButton) {
        emptySetPlaceholder?.buttonAction?()
    }
}
