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
    }

    private func loadSteps() {
        guard let lesson = lesson, let viewController = view as? UIViewController else { return }

        lesson.loadSteps(completion: {
            [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.steps = lesson.steps
            strongSelf.stepsViewData = strongSelf.steps.map {
                var s = StepViewData(with: $0)
                    s.setAction {
                        let stepVC = s.viewController
                            stepVC.modalPresentationStyle = .overFullScreen
                        viewController.present(stepVC, animated: true, completion: {})
                    }
                return s
            }
            strongSelf.view?.provide(steps: strongSelf.stepsViewData)
        }, error: { _ in }, onlyLesson: true)
    }
}

struct StepViewData {

    enum StepType: String {
        case video = "video"
        case text = "text"
        case choice = "choice"
        case free = "free"
        case string = "string"
        case number = "number"
        case unavailable = "unavailable"
    }

    let stepType: StepType
    let block: Block
    let isPassed: Bool?
    var action: (() -> Void)?

    init(with step: Step) {
        self.stepType = StepType(rawValue: step.block.name) ?? .unavailable
        self.block = step.block

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

    var viewController: UIViewController {
        switch stepType {
        case .video:
            print(stepType.rawValue)
            return UIViewController()
        case .text:
            let textPresenter = TVTextPresentationAlertController()
            textPresenter.setText(block.text!)
            print(stepType.rawValue)
            return textPresenter
        case .choice:
            print(stepType.rawValue)
            return UIViewController()
        case .free:
            print(stepType.rawValue)
            return UIViewController()
        case .string:
            print(stepType.rawValue)
            return UIViewController()
        case .number:
            print(stepType.rawValue)
            return UIViewController()
        case .unavailable:
            return UIViewController()
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
