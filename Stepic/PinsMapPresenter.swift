//
//  PinsMapPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 28.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol PinsMapContentView: class {
    func set(pins: [Int])
}

class PinsMapPresenter {
    weak var view: PinsMapContentView?

    init(view: PinsMapContentView?) {
        self.view = view
    }

    func update(with userActivity: UserActivity) {
        view?.set(pins: userActivity.pins)
    }
}
