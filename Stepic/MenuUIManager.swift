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
        case .titleContentExpandable:
            if let cell = cell as? TitleContentExpandableMenuBlockTableViewCell, let block = block as? TitleContentExpandableMenuBlock {
                cell.initWithBlock(block: block)
            }
        }
    }

    func getCell(forblock block: MenuBlock, indexPath: IndexPath) -> UITableViewCell {
        guard let blockType = SupportedMenuBlockType(block: block) else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: blockType.cellIdentifier, for: indexPath)

        initCell(cell: cell, withBlock: block, type: blockType)

        return cell
    }

    private func select(block: MenuBlock, type: SupportedMenuBlockType) {
        switch type {
        case .transition:
            if let block = block as? TransitionMenuBlock {
                block.onTouch?()
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

        select(block: block, type: blockType)
    }
}

enum SupportedMenuBlockType {
    case switchBlock
    case transition
    case titleContentExpandable

    static var all: [SupportedMenuBlockType] = [
        .switchBlock,
        .transition,
        .titleContentExpandable
    ]

    var nibName: String {
        switch self {
        case .switchBlock:
            return "SwitchMenuBlockTableViewCell"
        case .transition:
            return "TransitionMenuBlockTableViewCell"
        case .titleContentExpandable:
            return "TitleContentExpandableMenuBlockTableViewCell"
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
        if block is TitleContentExpandableMenuBlock {
            self = .titleContentExpandable
            return
        }
        if block is TransitionMenuBlock {
            self = .transition
            return
        }
        return nil
    }
}
