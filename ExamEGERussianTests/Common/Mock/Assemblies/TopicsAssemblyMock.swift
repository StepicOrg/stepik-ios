//
//  TopicsAssemblyMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 16/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
@testable import ExamEGERussian

final class TopicsAssemblyMock: TopicsAssembly {
    func module(navigationController: UINavigationController) -> UIViewController {
        return MockAssemblyViewController()
    }
}
