//
//  TrainingAssemblyMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 17/09/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
@testable import ExamEGERussian

final class TrainingAssemblyMock: TrainingAssemblyProtocol {
    func makeModule(navigationController: UINavigationController) -> UIViewController {
        return MockAssemblyViewController()
    }
}
