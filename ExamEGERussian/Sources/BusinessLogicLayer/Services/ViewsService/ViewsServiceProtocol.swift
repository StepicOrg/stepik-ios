//
//  ViewsServiceProtocol.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 23/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol ViewsServiceProtocol: class {
    /// Method is used to send view for step.
    ///
    /// - Parameter step: Step for which view will be send.
    /// - Returns: `Promise<Void>` if the view was sent successfully. Returns `error` if an error occurred.
    func sendView(for step: StepPlainObject) -> Promise<Void>
}
