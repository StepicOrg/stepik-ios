//
//  Collection+SafeSubscript.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 14.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

extension Collection {

    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
