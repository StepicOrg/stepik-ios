//
//  StringExtensions.swift
//  Stepic
//
//  Created by Alexander Karpov on 23.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

extension String {
    func getRequestParametersDictionary() -> [String : AnyObject] {
        var res: [String : AnyObject] = [:]

        var str = ""
        if let idx = self.index(of: "?") {
            let pos: Int = self.distance(from: self.startIndex, to: idx)
            str = self.substring(from: self.index(self.startIndex, offsetBy: pos + 1))
        }
        let arr: [String] = str.components(separatedBy: CharacterSet(charactersIn: "&="))

        for i in 0..<arr.count / 2 {
            res[arr[i * 2]] = arr[i * 2 + 1] as AnyObject
        }
        return res
    }

    func indexOf(_ target: String) -> Int? {
        if let range = self.range(of: target) {
            return self.distance(from: startIndex, to: range.lowerBound)
        } else {
            return nil
        }
    }

    func lastIndexOf(_ target: String) -> Int? {
        if let range = self.range(of: target, options: .backwards) {
            return self.distance(from: startIndex, to: range.lowerBound)
        } else {
            return nil
        }
    }
}
