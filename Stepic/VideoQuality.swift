//
//  VideoQuality.swift
//  Stepic
//
//  Created by Alexander Karpov on 22.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

enum VideoQuality : Int {
    case Low = 270, Medium = 360, High = 720, VeryHigh = 1080
    
    init(quality: Int) {
        if quality > High.rawValue {
            self = .VeryHigh
            return
        } 
        if quality > Medium.rawValue {
            self = .High
            return
        }
        if quality > Low.rawValue {
            self = .Medium
            return
        }
        self = .Low
    }
    
    init(quality: String) {
        switch quality {
        case "270" : self = .Low
        case "360" : self = .Medium
        case "720" : self = .High
        case "1080" : self = .VeryHigh
        default : self = .Low
        }
    }
    
    init(preferencesTag tag: Int) {
        switch tag {
        case 0: self = .Low
        case 1: self = .Medium
        case 2: self = .High
        case 3: self = .VeryHigh
        default: 
            print("wrong video quality preferences tag is being set!")
            self = .Low
        }
    }
    
    var preferencesTag : Int {
        switch self {
        case .Low : return 0
        case .Medium : return 1
        case .High : return 2
        case .VeryHigh : return 3
        }
    }
    
    var rawString : String {
        return "\(self.rawValue)"
    }
}