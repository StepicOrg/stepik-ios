//
//  DictionarySerializable.swift
//  Stepic
//
//  Created by Alexander Karpov on 06.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

/*
 DictionarySerializable protocol, which defines dictionary serialization methods
 */
protocol DictionarySerializable {
    func serializeToDictionary() -> [String: Any]
    init?(dictionary: [String: Any])
}
