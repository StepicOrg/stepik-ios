//
// Created by Ivan Magda on 02/08/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol StepsPagerPresenter: class {
    func refresh()
    func cancel()
    func selectShareStep(at index: Int)
}
