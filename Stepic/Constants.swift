//
//  Constants.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit

class Constants: NSObject {
    static var sharedConstants = Constants()
    private override init() {}
    
    let stepicURLString = "https://stepic.org/"
}
