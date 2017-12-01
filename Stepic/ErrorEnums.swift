//
//  ErrorEnums.swift
//  Stepic
//
//  Created by Alexander Karpov on 28.09.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

enum FetchError: Error {
    case requestExecution
}

enum ConnectionError: Error {
    case noDataRecievedError, parsingError, tokenRefreshError
}

enum WeakSelfError: Error {
    case noStrong
}
