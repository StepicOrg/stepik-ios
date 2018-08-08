//
//  Story.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 03.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import Foundation

class Story {
    var id: Int
    var coverPath: String
    var title: String
    var isViewed: CachedValue<Bool>
    var parts: [StoryPart]
    
    init(id: Int, coverPath: String, title: String, isViewed: Bool, parts: [StoryPart]) {
        self.id = id
        self.coverPath = coverPath
        self.title = title
        self.isViewed = CachedValue<Bool>(key: "isViewed", value: isViewed)
        self.parts = parts
    }
    
}

class StoryPart {
    var type: String
    var position: Int
    var duration: Double
    
    init(type: String, position: Int, duration: Double) {
        self.type = type
        self.position = position
        self.duration = duration
    }
}

protocol ImageStoryPartProtocol {
    var imagePath: String {get set}
}

class ImageStoryPart: StoryPart, ImageStoryPartProtocol {
    var imagePath: String
    
    init(type: String, position: Int, duration: Double, imagePath: String) {
        self.imagePath = imagePath
        super.init(type: type, position: position, duration: duration)
    }
}

class TextStoryPart: StoryPart {
    var title: String
    var text: String
    var imagePath: String
    
    init(type: String, position: Int, duration: Double, title: String, text: String, imagePath: String) {
        self.title = title
        self.text = text
        self.imagePath = imagePath
        super.init(type: type, position: position, duration: duration)
    }
}
