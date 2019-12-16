//
//  PersistentUserTokenRecoveryManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 07.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

/*
 A PersistentRecoveryManager for StepicToken object
 */
final class PersistentUserTokenRecoveryManager: PersistentRecoveryManager {
    override func recoverObjectFromDictionary(_ dictionary: [String: Any]) -> DictionarySerializable? {
        StepicToken(dictionary: dictionary)
    }

    func recoverStepicToken(userId: Int) -> StepicToken? {
        self.recoverObjectWithKey("\(userId)") as? StepicToken
    }

    func writeStepicToken(_ token: StepicToken, userId: Int) {
        self.writeObjectWithKey("\(userId)", object: token)
    }
}
