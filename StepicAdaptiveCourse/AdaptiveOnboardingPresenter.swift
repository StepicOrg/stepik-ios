//
//  AdaptiveOnboardingPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 07.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol AdaptiveOnboardingView: class {
    func finishOnboarding()
}

class AdaptiveOnboardingPresenter {
    weak var view: AdaptiveOnboardingView?
    
    let onboardingSteps = [
        AdaptiveOnboardingStep(title: "Добро пожаловать", text: "Добро пожаловать!", requiredActions: [.clickButton], buttonTitle: "Далее", isButtonHidden: false),
        AdaptiveOnboardingStep(title: "Смахивание влево", text: "Смахните влево, если сложно", requiredActions: [.swipeLeft], buttonTitle: "", isButtonHidden: true),
        AdaptiveOnboardingStep(title: "Смахивание вправо", text: "Смахните вправо, если легко", requiredActions: [.swipeRight], buttonTitle: "", isButtonHidden: true),
    ]
    private var onboardingStepIndex = 0
    
    init(view: AdaptiveOnboardingView) {
        self.view = view
    }
    
    func getNextCardData() -> AdaptiveOnboardingStep? {
        if onboardingStepIndex == onboardingSteps.count {
            return nil
        }
        
        let step = onboardingSteps[onboardingStepIndex]
        onboardingStepIndex += 1
        return step
    }
    
    func finishOnboarding() {
        view?.finishOnboarding()
    }
}
