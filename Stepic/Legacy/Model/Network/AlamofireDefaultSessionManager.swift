//
//  AlamofireDefaultSessionManager.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 16.04.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Alamofire

final class AlamofireDefaultSessionManager: Alamofire.Session {
    static let shared = Alamofire.Session(configuration: StepikURLSessionConfiguration.default)
}
