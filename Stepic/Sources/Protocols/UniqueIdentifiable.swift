//
//  UniqueIdentifiable.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 21.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

typealias UniqueIdentifierType = String

protocol UniqueIdentifiable {
    var uniqueIdentifier: UniqueIdentifierType { get }
}
