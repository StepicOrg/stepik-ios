//
//  ImageConstants.swift
//  Stepic
//
//  Created by Alexander Karpov on 21.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

struct Images {
    static let downloadFromCloud = UIImage(named: "Download From Cloud Bounded")!
    static let downloadFromCloudWhite = UIImage(named: "Download From Cloud Bounded White")!

    static let delete = UIImage(named: "Delete Bounded")!
    static let deleteWhite = UIImage(named: "Delete Bounded White")!
    
    static let videoPlaceholder = UIImage(named: "video_placeholder")!
    static let emptyDownloadsPlaceholder = UIImage(named: "nodownloads250")!
    static let emptyCoursesPlaceholder = UIImage(named: "nocourses250")!

    static let safariBarButtonItemImage = UIImage(named: "Safari")!
    static let backBarButtonItemImage = UIImage(named: "Back-1")!
    static let crossBarButtonItemImage = UIImage(named: "Cross")!

    static let visibleImage = UIImage(named: "visible")!
    static let visibleFilledImage = UIImage(named: "visible_filled")!
    
    static let correctQuizImage = UIImage(named: "ic_correct")!
    static let wrongQuizImage = UIImage(named: "ic_error")!
    
    struct noWifiImage {
        static let size250x250 = UIImage(named: "nowifi_dark_250")!
        static let size100x100 = UIImage(named: "nowifi_dark_100")!
        static let white = UIImage(named: "no-wifi-white")!
    }    
    
    struct lessonPlaceholderImage {
        static let size50x50 = UIImage(named: "lesson_cover_50")!
    }
    
    struct playerControls {
        static let play = UIImage(named: "ic_play_arrow_48pt")!
        static let pause = UIImage(named: "ic_pause_48pt")!
        static let timeSliderThumb = UIImage(named: "thumb_image_15")!
    }
    
    struct solvedTask {
        static let green = UIImage(named: "ic_solved_task")!
        static let white = UIImage(named: "ic_solved_task_white")!
    }
    
    struct appIcon {
        static let size40x40 = UIImage(named: "AppIcon40x40")!
    }
    
    static let boundedStepicIcon = UIImage(named: "boundedStepicIcon")!
    
    static let sendImage = UIImage(named: "Sent-100")!
    static let checkMarkImage = UIImage(named: "Checkmark-100")!
    
    struct noCommentsWhite {
        static let size200x200 = UIImage(named: "nocomments-white")!
    }
    
    struct thumbsUp {
        static let normal = UIImage(named: "Thumb Up Gray")!
        static let filled = UIImage(named: "Thumb Up Green")!
    }
    
    struct points {
        static let vertical = UIImage(named: "Points_vertical")!
    }
    
    struct streak {
        static let black = UIImage(named: "streak-icon-black")!
        static let white = UIImage(named: "streak-icon-white-bordered")!
    }
    
    struct star {
        static let empty = UIImage(named: "star_gray")!
        static let filled = UIImage(named: "star_yellow")!
    }

}
