//
//  ErrorEnums.swift
//  Stepic
//
//  Created by Alexander Karpov on 28.09.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

enum FetchError : ErrorType {
    case RequestExecution
}

enum ConnectionError : ErrorType {
    case NoDataRecievedError, ParsingError, TokenRefreshError
}