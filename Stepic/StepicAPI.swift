//
//  StepicAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit

class StepicAPI: NSObject {
    static var shared = StepicAPI()
    
    private override init() {}
    
    var token : StepicToken?
}
