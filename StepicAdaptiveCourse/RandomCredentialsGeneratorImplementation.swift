//
//  RandomCredentialsGeneratorImplementation.swift
//  Stepic
//
//  Created by Ivan Magda on 06/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct RandomCredentialsGeneratorImplementation {
}

extension RandomCredentialsGeneratorImplementation: RandomCredentialsGenerator {

    var firstname: String {
        return StringHelper.generateRandomString(of: 6)
    }

    var lastname: String {
        return StringHelper.generateRandomString(of: 6)
    }

    var email: String {
        return "adaptive_\(StepicApplicationsInfo.adaptiveSupportedCourses.first ?? 0)_ios_\(Int(Date().timeIntervalSince1970))\(StringHelper.generateRandomString(of: 5))@stepik.org"
    }

    var password: String {
        return StringHelper.generateRandomString(of: 16)
    }

}
