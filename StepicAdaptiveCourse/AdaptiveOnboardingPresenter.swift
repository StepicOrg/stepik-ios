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
    func updateProgress(for current: Int, count: Int)
}

class AdaptiveOnboardingPresenter {
    weak var view: AdaptiveOnboardingView?
    
    private var achievementManager: AchievementManager?
    
    private var onboardingSteps: [AdaptiveOnboardingStep] = []
    var onboardingStepIndex = 0
    
    init(achievementManager: AchievementManager?, view: AdaptiveOnboardingView) {
        self.view = view
        self.achievementManager = achievementManager
        
        onboardingSteps = [AdaptiveOnboardingStep(title: NSLocalizedString("WelcomeTitle", comment: ""), content: loadOnboardingStep(from: "step1"), requiredActions: [.clickButton], buttonTitle: NSLocalizedString("NextTask", comment: ""), isButtonHidden: false),
        AdaptiveOnboardingStep(title: NSLocalizedString("SwipeLeftTitle", comment: ""), content: loadOnboardingStep(from: "step2"), requiredActions: [.swipeLeft], buttonTitle: "", isButtonHidden: true),
        AdaptiveOnboardingStep(title: NSLocalizedString("SwipeRightTitle", comment: ""), content: loadOnboardingStep(from: "step3"), requiredActions: [.swipeRight], buttonTitle: "", isButtonHidden: true),
        AdaptiveOnboardingStep(title: NSLocalizedString("ProgressTitle", comment: ""), content: loadOnboardingStep(from: "step4"), requiredActions: [.clickButton], buttonTitle: NSLocalizedString("NextTask", comment: ""), isButtonHidden: false),
        AdaptiveOnboardingStep(title: NSLocalizedString("ProgressTitle", comment: ""), content: loadOnboardingStep(from: "step5"), requiredActions: [.clickButton], buttonTitle: NSLocalizedString("FinishOnboarding", comment: ""), isButtonHidden: false)
        ]
    }
    
    func getNextCardData() -> AdaptiveOnboardingStep? {
        if onboardingStepIndex == onboardingSteps.count {
            return nil
        }
        
        view?.updateProgress(for: onboardingStepIndex, count: onboardingSteps.count)
        let step = onboardingSteps[onboardingStepIndex]
        
        // 4 – num of step about progress, rating and achievements
        if onboardingStepIndex == 4 {
            achievementManager?.fireEvent(.onboarding)
        }
        
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
            let baseUrl = URL(fileURLWithPath: filePath)
            return (text: contents, baseURL: baseUrl)
        } catch {
            return (text: nil, baseURL: nil)
        }
    }
}
