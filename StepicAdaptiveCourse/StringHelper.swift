//
//  StringHelper.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 05.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class StringHelper {
    static func generateRandomString(of length: Int) -> String {
        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)

        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
    }

    static func pluralize(number: Int, forms: [String]) -> String {
        return number % 10 == 1 && number % 100 != 11 ? forms[0] :
            (number % 10 >= 2 && number % 10 <= 4 && (number % 100 < 10 || number % 100 >= 20) ? forms[1] : forms[2])
    }
}
