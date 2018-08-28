//
//  PromiseReturnable.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 16/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

class BaseServiceMock<T> {
    var resultToBeReturned: Promise<T> = Promise(error: NSError.mockError)
}
