//
//  AdaptiveOnboardingPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 07.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

typealias AdaptiveOnboardingStep = (() -> ())

protocol AdaptiveOnboardingView: class {

}

class AdaptiveOnboardingPresenter {
    weak var view: AdaptiveOnboardingView?
    
    init(view: AdaptiveOnboardingView) {
        self.view = view
    }
}
