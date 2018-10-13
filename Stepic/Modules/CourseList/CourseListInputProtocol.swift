//
//  CourseListInputProtocol.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol CourseListInputProtocol: class {
    var moduleIdentifier: UniqueIdentifierType? { get set }

    /// Course list will be use data from network
    func setOnlineStatus()
}
