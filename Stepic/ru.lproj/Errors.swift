//
//  Errors.swift
//  Stepic
//
//  Created by Ostrenkiy on 08.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire

//Is used for handling errors in network requests
enum NetworkError {
    case badStatus(Int)
    case connectionProblem
    case other(Any)

    init(e: AFError) {
        switch e {

        }
    }
}

//Is used for handling errors in data parsing
enum ParsingError {
    case badData
}

//Is used for handling unwrapping errors. Mostly useful in promises
enum UnwrappingError {
    case optionalError
}

//Is used for handling errors in CoreData
enum DatabaseError {
    case fetchFailed
}
