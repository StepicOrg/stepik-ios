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
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initWithCourse(course: Course) {
        videoWebView.loadRequest(NSURLRequest(URL: NSURL(string: course.introURL)!))
    }
    
}
