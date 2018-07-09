//
//  RandomCredentialsGenerator.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 06/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol RandomCredentialsGenerator {

    var firstname: String { get }

    var lastname: String { get }

    var email: String { get }

    var password: String { get }

}
