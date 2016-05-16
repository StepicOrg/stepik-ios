//
//  Notification.swift
//  Stepic
//
//  Created by Alexander Karpov on 13.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class Notification : DictionarySerializable {
    var type : NotificationType
    var htmlText: String
    
    required init?(dictionary: [String : AnyObject]) {
        if let typeString = dictionary["type"] as? String {
            if let type =  NotificationType(rawValue: typeString) {
                self.type = type
            } else {
                return nil
            }
        } else {
            return nil
        }
        
        if let htmlText = dictionary["html_text"] as? String {
            self.htmlText = htmlText
        } else {
            return nil
        }
    }
    
    init(type: NotificationType, htmlText: String) {
        self.type = type
        self.htmlText = htmlText
    }
    
    func serializeToDictionary() -> [String : AnyObject] {
        return [String: AnyObject]()
    }
    
}