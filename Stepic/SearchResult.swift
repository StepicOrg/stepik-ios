//
//  SearchResult.swift
//  Stepic
//
//  Created by Alexander Karpov on 12.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftyJSON

class SearchResult: NSObject {
    
    var score : Float
    var courseId : Int?
    var lessonId : Int?
    var stepId : Int?
    var commentId : Int?
    
    init(json: JSON) {
        self.score = json["score"].floatValue
        self.courseId = json["course"].int
        self.lessonId = json["lesson"].int
        self.stepId = json["step"].int
        self.commentId = json["comment"].int
        super.init()
    }
}
