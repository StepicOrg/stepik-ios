//
// Created by Ivan Magda on 11/9/18.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation

enum CourseInfoTabInfoBlockViewBuilder {
    static func build(viewModel: CourseInfoTabInfoBlockViewModelProtocol) -> UIView? {
        switch viewModel.blockType {
        case .introVideo:
            guard let introVideoViewModel = viewModel as? CourseInfoTabInfoIntroVideoBlockViewModel,
                  let _ = introVideoViewModel.introURL else {
                return nil
            }

            let imageView = UIImageView(image: UIImage(named: "new-coursepics-python-xl"))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true

            return imageView
        case .instructors:
            guard let instructorsViewModel = viewModel as? CourseInfoTabInfoInstructorsBlockViewModel else {
                return nil
            }

            return CourseInfoTabInfoInstructorsBlockView(viewModel: instructorsViewModel)
        default:
            guard let textBlockViewModel = viewModel as? CourseInfoTabInfoTextBlockViewModel else {
                return nil
            }

            return CourseInfoTabInfoTextBlockView(
                appearance: self.getTextBlockAppearance(for: viewModel.blockType),
                viewModel: textBlockViewModel
            )
        }
    }

    private static func getTextBlockAppearance(
        for type: CourseInfoTabInfoBlockType
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
