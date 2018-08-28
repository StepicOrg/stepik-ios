//
//  ReactionServiceProtocol.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 17/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol ReactionServiceProtocol: class {
    /// The method is used for sending user reaction for the lesson.
    ///
    /// - Parameters:
    ///   - reaction: User `Reaction` for a lesson. See `Reaction` enum for more info about supported types.
    ///   - lessonId: Unique identifier of the lesson for which reaction is sending.
    ///   - userId: Unique identifier of the user which is sending the reaction.
    /// - Returns: Promise with `Void` type, catch on error.
    func sendReaction(_ reaction: Reaction, forLesson lessonId: Int, byUser userId: Int) -> Promise<Void>
}
