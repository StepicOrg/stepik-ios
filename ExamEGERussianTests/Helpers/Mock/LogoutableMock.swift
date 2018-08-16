//
//  LogoutableMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 15/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
@testable import ExamEGERussian

final class LogoutableMock: Logoutable {
    func logout(completion: (() -> Void)?) {
        completion?()
    }
}
