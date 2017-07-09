//
//  AdaptiveOnboardingStep.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 09.07.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

enum AdaptiveOnboardingAction {
    case swipeLeft
    case swipeRight
    case clickButton
}

struct AdaptiveOnboardingStep {
    let title: String
    let text: String
    let requiredActions: [AdaptiveOnboardingAction]
    let buttonTitle: String
    let isButtonHidden: Bool
}
