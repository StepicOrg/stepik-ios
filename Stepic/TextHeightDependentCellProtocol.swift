//
//  TextHeightDependentCellProtocol.swift
//  Stepic
//
//  Created by Alexander Karpov on 06.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

protocol TextHeightDependentCellProtocol : class {
    func setHTMLText(text: String) -> (Void -> Int)
}