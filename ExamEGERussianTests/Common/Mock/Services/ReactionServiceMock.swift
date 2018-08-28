//
//  ReactionServiceMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 21/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
@testable import ExamEGERussian

final class ReactionServiceMock: BaseServiceMock<Void>, ReactionServiceProtocol {
    func sendReaction(_ reaction: Reaction, forLesson lessonId: Int, byUser userId: Int) -> Promise<Void> {
        return resultToBeReturned
    }
}
