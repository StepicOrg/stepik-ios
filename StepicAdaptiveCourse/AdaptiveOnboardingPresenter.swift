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
    
    private var onboardingSteps: [AdaptiveOnboardingStep] = []
    private var onboardingStepIndex = 0
    
    init(view: AdaptiveOnboardingView) {
        self.view = view
        
        onboardingSteps = [AdaptiveOnboardingStep(title: NSLocalizedString("WelcomeTitle", comment: ""), content: loadOnboardingStep(from: "step1"), requiredActions: [.clickButton], buttonTitle: NSLocalizedString("NextTask", comment: ""), isButtonHidden: false),
        AdaptiveOnboardingStep(title: NSLocalizedString("SwipeLeftTitle", comment: ""), content: loadOnboardingStep(from: "step2"), requiredActions: [.swipeLeft], buttonTitle: "", isButtonHidden: true),
        AdaptiveOnboardingStep(title: NSLocalizedString("SwipeRightTitle", comment: ""), content: loadOnboardingStep(from: "step3"), requiredActions: [.swipeRight], buttonTitle: "", isButtonHidden: true)
        ]
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
    
    fileprivate func loadOnboardingStep(from file: String) -> AdaptiveOnboardingStep.TextContent {
        guard let filePath = Bundle.main.path(forResource: file, ofType: "html") else {
            return (text: nil, baseURL: nil)
        }
    
        do {
            let contents = try String(contentsOfFile: filePath, encoding: .utf8)
            print(contents)
            let baseUrl = URL(fileURLWithPath: filePath)
            return (text: contents, baseURL: baseUrl)
        } catch {
            return (text: nil, baseURL: nil)
        }
    }
}
