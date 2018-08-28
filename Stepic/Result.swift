//
//  Result.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(Error)
}
