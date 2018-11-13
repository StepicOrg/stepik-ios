//
// Created by Ivan Magda on 11/9/18.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation

enum CourseInfoTabInfoBlockViewBuilder {
    static func build(viewModel: CourseInfoTabInfoBlockViewModelProtocol) -> UIView? {
        switch viewModel {
        case let textBlockViewModel as CourseInfoTabInfoTextBlockViewModel:
            let view = CourseInfoTabInfoTextBlockView(
                appearance: self.getTextBlockAppearance(for: viewModel.blockType)
            )
            view.configure(viewModel: textBlockViewModel)
            return view
        case let introVideoViewModel as CourseInfoTabInfoIntroVideoBlockViewModel:
            let view = CourseInfoTabInfoIntroVideoBlockView()
            view.configure(viewModel: introVideoViewModel)
            return view
        case let instructorsViewModel as CourseInfoTabInfoInstructorsBlockViewModel:
            let view = CourseInfoTabInfoInstructorsBlockView()
            view.configure(viewModel: instructorsViewModel)
            return view
        default:
            print("Not supported block view model: \(viewModel)")
            return nil
        }
    }

    private static func getTextBlockAppearance(
        for type: CourseInfoTabInfoBlock
    ) -> CourseInfoTabInfoTextBlockView.Appearance {
        switch type {
        case .author:
            return .init(
                headerViewInsets: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 47),
                messageLabelInsets: UIEdgeInsets(top: 20, left: 47, bottom: 0, right: 47)
            )
        case .about:
            return .init(
                headerViewInsets: UIEdgeInsets(top: 18, left: 20, bottom: 0, right: 47),
                messageLabelInsets: UIEdgeInsets(top: 20, left: 47, bottom: 0, right: 47)
            )
        case .requirements:
            return .init(
                headerViewInsets: UIEdgeInsets(top: 32, left: 20, bottom: 0, right: 47),
                messageLabelInsets: UIEdgeInsets(top: 17, left: 47, bottom: 0, right: 47)
            )
        case .targetAudience:
            return .init(
                headerViewInsets: UIEdgeInsets(top: 37, left: 20, bottom: 0, right: 47),
                messageLabelInsets: UIEdgeInsets(top: 17, left: 47, bottom: 0, right: 47)
            )
        case .timeToComplete, .language, .certificate:
            return .init(
                headerViewInsets: UIEdgeInsets(top: 37, left: 20, bottom: 0, right: 47),
                messageLabelInsets: UIEdgeInsets(top: 3, left: 47, bottom: 0, right: 47)
            )
        case .certificateDetails:
            return .init(
                headerViewInsets: UIEdgeInsets(top: 43, left: 20, bottom: 0, right: 47),
                messageLabelInsets: UIEdgeInsets(top: 3, left: 47, bottom: 0, right: 47)
            )
        default:
            return .init(
                headerViewInsets: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 47),
                messageLabelInsets: UIEdgeInsets(top: 20, left: 47, bottom: 0, right: 47)
            )
        }
    }
}
