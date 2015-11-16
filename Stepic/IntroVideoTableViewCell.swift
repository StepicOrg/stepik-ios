//
//  IntroVideoTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 01.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

class IntroVideoTableViewCell: UITableViewCell {

    @IBOutlet weak var videoWebView: UIWebView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        videoWebView.scrollView.scrollEnabled = false
        videoWebView.scrollView.bouncesZoom = false
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initWithCourse(course: Course) {
//        print(course.introURL)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.videoWebView.loadRequest(NSURLRequest(URL: NSURL(string: course.introURL)!))
        }
    }
    
}
