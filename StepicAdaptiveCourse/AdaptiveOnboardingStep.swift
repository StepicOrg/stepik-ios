//
//  AdaptiveOnboardingStep.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 09.07.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

enum AdaptiveOnboardingAction {
    case swipeLeft    // user should swipe left
    case swipeRight   // user should swipe right
    case clickButton  // user should click button
}

struct AdaptiveOnboardingStep {
    // We load html, so we should know base url
    typealias TextContent = (text: String?, baseURL: URL?)

    let title: String
    let content: TextContent
    let requiredActions: [AdaptiveOnboardingAction]
    let buttonTitle: String
    let isButtonHidden: Bool
}
