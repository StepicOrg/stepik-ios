//
//  VideoDownload.swift
//  Stepic
//
//  Created by Alexander Karpov on 06.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

class VideoDownload: NSObject {
    
    var download : TCBlobDownload
    var videoId : Int
    var lessonId : Int?
    var sectionId : Int?
    
    var progress : Float {
        return download.progress
    }
    
    init(download : TCBlobDownload, videoId : Int) {
        self.download = download
        self.videoId = videoId
    }
}
