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
        var res : [String : AnyObject] = [:]
        
        var str = ""
        if let idx = self.characters.indexOf("?") {
            let pos : Int = self.startIndex.distanceTo(idx)
            str = self.substringFromIndex(self.startIndex.advancedBy(pos+1))
        }
        
        let arr : [AnyObject] = str.characters.split(isSeparator: { $0 == "&" || $0 == "="}).map(String.init)
        
        for i in 0..<arr.count/2 {
            res[arr[i*2] as! String] = arr[i*2+1] as AnyObject
        }
        return res
    }
}