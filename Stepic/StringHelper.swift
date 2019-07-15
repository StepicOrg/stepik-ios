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

    static func cyrillicToLatin(_ str: String) -> String {
        let cyr2Lat = ["а": "a", "б": "b", "в": "v", "г": "g", "д": "d", "е": "e", "ё": "e", "ж": "zh", "з": "z",
                       "и": "i", "й": "y", "к": "k", "л": "l", "м": "m", "н": "n", "о": "o", "п": "p", "р": "r",
                       "с": "s", "т": "t", "у": "u", "ф": "f", "х": "h", "ц": "c", "ч": "ch", "ш": "sh", "щ": "sch",
                       "ь": "\"", "ы": "y", "ъ": "\"", "э": "e", "ю": "yu", "я": "ya", "А": "A", "Б": "B", "В": "V",
                       "Г": "G", "Д": "D", "Е": "E", "Ё": "E", "Ж": "Zh", "З": "Z", "И": "I", "Й": "Y", "К": "K",
                       "Л": "L", "М": "M", "Н": "N", "О": "O", "П": "P", "Р": "R", "С": "S", "Т": "T", "У": "U",
                       "Ф": "F", "Х": "H", "Ц": "C", "Ч": "Ch", "Ш": "Sh", "Щ": "Sch", "Ь": "\"", "Ы": "Y",
                       "Ъ": "\"", "Э": "E", "Ю": "Yu", "Я": "Ya"]
        var res = ""
        for char in str {
            res += cyr2Lat[String(char)] ?? String(char)
        }
        return res
    }
}
