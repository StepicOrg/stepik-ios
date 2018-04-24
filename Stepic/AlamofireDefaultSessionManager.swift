//
//  AlamofireDefaultSessionManager.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 16.04.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Alamofire

class AlamofireDefaultSessionManager: Alamofire.SessionManager {
    static let shared = Alamofire.SessionManager(configuration: StepikURLSessionConfiguration.default)
}
