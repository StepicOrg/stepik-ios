//
//  DiscussionCellDelegate.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

protocol DiscussionCellDelegate : class {
    func didSelect(indexPath: NSIndexPath, deselectBlock: (Void -> Void))
}