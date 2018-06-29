//
//  MenuUIManager.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class MenuUIManager {
    var tableView: UITableView

    init(tableView: UITableView) {
        self.tableView = tableView
        registerNibsForSupportedTypes()
    }

    private func registerNibsForSupportedTypes() {
        for blockType in SupportedMenuBlockType.all {
            tableView.register(UINib(nibName: blockType.nibName, bundle: nil), forCellReuseIdentifier: blockType.cellIdentifier)
        }
    }

    private func initCell(cell: UITableViewCell, withBlock block: MenuBlock, type: SupportedMenuBlockType) {
        switch type {
        case .switchBlock:
            if let cell = cell as? SwitchMenuBlockTableViewCell, let block = block as? SwitchMenuBlock {
                cell.initWithBlock(block: block)
            }
        case .transition:
            if let cell = cell as? TransitionMenuBlockTableViewCell, let block = block as? TransitionMenuBlock {
                cell.initWithBlock(block: block)
            }
        case .contentExpandable:
            if let cell = cell as? ContentExpandableMenuBlockTableViewCell, let block = block as? ContentExpandableMenuBlock {
                cell.initWithBlock(block: block)
                cell.updateTableHeightBlock = {
                    [weak self] in
                    self?.tableView.beginUpdates()
                    self?.tableView.endUpdates()
                }
            }
        case .content:
            if let cell = cell as? ContentMenuBlockTableViewCell, let block = block as? ContentMenuBlock {
                cell.initWithBlock(block: block)
            }
        case .header:
            if let cell = cell as? HeaderMenuBlockTableViewCell, let block = block as? HeaderMenuBlock {
                cell.initWithBlock(block: block)
            }
        case .placeholder:
            if let cell = cell as? PlaceholderTableViewCell, let block = block as? PlaceholderMenuBlock {
                cell.initWithBlock(block: block)
            }
        }

        block.cell = cell
    }

    func getCell(forblock block: MenuBlock, indexPath: IndexPath) -> UITableViewCell {
        guard let blockType = SupportedMenuBlockType(block: block) else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: blockType.cellIdentifier, for: indexPath)

        initCell(cell: cell, withBlock: block, type: blockType)

        return cell
    }

    private func select(block: MenuBlock, type: SupportedMenuBlockType, indexPath: IndexPath) {
        switch type {
        case .transition:
            if let block = block as? TransitionMenuBlock {
                block.onTouch?()
            }
        case .contentExpandable:
            if let cell = tableView.cellForRow(at: indexPath) as? ContentExpandableMenuBlockTableViewCell {
                cell.expandPressed()
            }
        default:
            break
        }
    }

    func didSelect(block: MenuBlock, indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }

        guard let blockType = SupportedMenuBlockType(block: block) else {
            return
        }

        select(block: block, type: blockType, indexPath: indexPath)
    }

    func shouldSelect(block: MenuBlock, indexPath: IndexPath) -> Bool {
        guard let type = SupportedMenuBlockType(block: block) else {
            return false
        }
        switch type {
        case .contentExpandable:
            return true
        default:
            return block.isSelectable
        }
    }

    func prepareToRemove(at indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? MenuBlockTableViewCell {
            cell.animateHide()
        }
    }
}

enum SupportedMenuBlockType {
    case switchBlock
    case transition
    case contentExpandable
    case header
    case placeholder
    case content

    static var all: [SupportedMenuBlockType] = [
        .switchBlock,
        .transition,
        .contentExpandable,
        .header,
        .placeholder,
        .content
    ]

    var nibName: String {
        switch self {
        case .switchBlock:
            return "SwitchMenuBlockTableViewCell"
        case .transition:
            return "TransitionMenuBlockTableViewCell"
        case .contentExpandable:
            return "ContentExpandableMenuBlockTableViewCell"
        case .header:
            return "HeaderMenuBlockTableViewCell"
        case .placeholder:
            return "PlaceholderTableViewCell"
        case .content:
            return "ContentMenuBlockTableViewCell"
        }
    }

    var cellIdentifier: String {
        return nibName
    }

    init?(block: MenuBlock) {
        if block is SwitchMenuBlock {
            self = .switchBlock
            return
        }
        if block is ContentExpandableMenuBlock {
            self = .contentExpandable
            return
        }
        if block is TransitionMenuBlock {
            self = .transition
            return
        }
        if block is HeaderMenuBlock {
            self = .header
            return
        }
        if block is PlaceholderMenuBlock {
            self = .placeholder
            return
        }
        if block is ContentMenuBlock {
            self = .content
            return
        }
        return nil
    }
}
