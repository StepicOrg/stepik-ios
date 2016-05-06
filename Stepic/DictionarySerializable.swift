//
//  DictionarySerializable.swift
//  Stepic
//
//  Created by Alexander Karpov on 06.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

/*
 DictionarySerializer protocol, which defines serialization methods
 */
protocol DictionarySerializer {
    func serialize(object: AnyObject) -> [String: AnyObject]?
    func deserialize(dictionary dict: [String: AnyObject]) -> AnyObject?
}