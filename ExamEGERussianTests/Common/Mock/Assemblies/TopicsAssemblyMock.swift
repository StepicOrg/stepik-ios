//
//  TopicsAssemblyMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 16/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
@testable import ExamEGERussian

final class TopicsAssemblyMock: TrainingAssemblyProtocol {
    func learning(navigationController: UINavigationController) -> UIViewController {
        return MockAssemblyViewController()
    }

    func training(navigationController: UINavigationController) -> UIViewController {
        return MockAssemblyViewController()
    }
}
