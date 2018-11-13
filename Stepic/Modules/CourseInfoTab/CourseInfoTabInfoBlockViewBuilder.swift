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
                headerViewInsets: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 47)
            )
        default:
            return .init(
                headerViewInsets: UIEdgeInsets(top: 40, left: 20, bottom: 0, right: 47)
            )
        }
    }
}
