//
//  DiscussionUpdateDelegate.swift
//  Stepic
//
//  Created by Alexander Karpov on 13.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

protocol DiscussionUpdateDelegate : class {
    func update(section: Int?, completion: (() -> Void)?)
}
