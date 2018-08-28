//
//  ViewsServiceMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 23/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
@testable import ExamEGERussian

final class ViewsServiceMock: BaseServiceMock<Void>, ViewsServiceProtocol {
    func sendView(for step: StepPlainObject) -> Promise<Void> {
        return resultToBeReturned
    }
}
