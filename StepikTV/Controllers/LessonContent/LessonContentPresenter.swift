//
//  LessonContentPresenter.swift
//  StepikTV
//
//  Created by Александр Пономарев on 19.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit

class LessonContentPresenter {

    weak var view: LessonContentView?

    var lesson: Lesson? {
        didSet { loadSteps() }
    }

    private var steps: [Step] = []
    private var stepsViewData: [StepViewData] = []

    init(view: LessonContentView) {
        self.view = view

        NotificationCenter.default.addObserver(self, selector: #selector(self.stepUpdateNotification(_:)), name: .stepUpdated, object: nil)
    }

    @objc private func stepUpdateNotification(_ notification: NSNotification) {
        if let stepId = notification.userInfo?["id"] as? Int {
            view?.update(at: stepId - 1)
        }
    }

    private func loadSteps() {
        guard let lesson = lesson, let viewController = view as? UIViewController else { return }

        view?.showLoading()
        lesson.loadSteps(completion: {
            [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.steps = lesson.steps
            strongSelf.stepsViewData = strongSelf.steps.map {
                var s = StepViewData(with: $0)
                    s.setAction {
                        let stepVC = s.stepViewController
                            stepVC.modalPresentationStyle = .overFullScreen
                        viewController.present(stepVC, animated: true, completion: {})
                    }
                return s
            }
            strongSelf.view?.hideLoading()
            strongSelf.view?.provide(steps: strongSelf.stepsViewData)
        }, error: { _ in }, onlyLesson: true)
    }
}

struct StepViewData {

    enum StepType: String {
        case video = "video"
        case text = "text"
        case choice = "choice"
        case string = "string"
        case number = "number"
        case unavailable = "unavailable"
    }
    let step: Step
    let stepType: StepType
    let block: Block
    var isPassed: Bool?
    var action: (() -> Void)?

    init(with step: Step) {
        self.stepType = StepType(rawValue: step.block.name) ?? .unavailable
        self.block = step.block
        self.step = step

        self.isPassed = step.progress?.isPassed
    }

    mutating func setAction(_ action: @escaping () -> Void) {
        self.action = action
    }

    var placeholderColor: UIColor {
        switch (isPassed) {
        case true? : return UIColor(hex: 0xd8d8d8)
        default : return UIColor(hex: 0x80c972)
        }
    }

    var stepViewController: UIViewController {
        switch stepType {
        case .video:
            let videoStepVC = VideoStepViewController()
                videoStepVC.video = block.video
                videoStepVC.stepPosition = self.step.position
            return videoStepVC
        default:
            let stepVC = ControllerHelper.instantiateViewController(identifier: "StepViewController", storyboardName: "StepViewController") as! StepViewController
                stepVC.stepViewData = self
            return stepVC
        }
    }

    var quizViewController: TVQuizViewController? {
        switch stepType {
        case .video:
            print(stepType.rawValue)
            return nil
        case .text:
            print(stepType.rawValue)
            return nil
        case .choice:
            print(stepType.rawValue)
            let vc = TVChoiceQuizViewController(nibName: "TVQuizViewController", bundle: nil)
            return vc
        case .string:
            print(stepType.rawValue)
            let vc = TVStringQuizViewController(nibName: "TVQuizViewController", bundle: nil)
            return vc
        case .number:
            print(stepType.rawValue)
            let vc = TVNumberQuizViewController(nibName: "TVQuizViewController", bundle: nil)
            return vc
        case .unavailable:
            let vc = TVUnavailableQuizViewController(nibName: "TVQuizViewController", bundle: nil)
            return vc
        }
    }

    var icon: UIImage {
        switch stepType {
        case .video : return #imageLiteral(resourceName: "video_icon")
        case .text : return #imageLiteral(resourceName: "text_icon")
        default: return #imageLiteral(resourceName: "task_icon")
        }
    }
}
