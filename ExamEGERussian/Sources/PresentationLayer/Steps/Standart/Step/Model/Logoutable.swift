//
//  Logoutable.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 15/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol Logoutable: class {
    func logout(completion: (() -> Void)?)
}

extension Logoutable {
    func logout() {
        logout(completion: nil)
    }
}
