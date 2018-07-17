//
//  AuthInfo+FakeUser.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 17/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

extension AuthInfo {
    enum FakeStatus: String {
        case yes
        case no
        case notExist
    }

    private static let fakeKey = "fake_user_status"

    var isFake: FakeStatus {
        get {
            let value = UserDefaults.standard.string(forKey: AuthInfo.fakeKey)
            if value == nil || value == FakeStatus.notExist.rawValue {
                return .notExist
            } else if value == FakeStatus.yes.rawValue {
                return .yes
            } else {
                return .no
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: AuthInfo.fakeKey)
        }
    }
}
