//
//  CoursePreviewTableViewCell.swift
//  Stepic
//
//  Created by Anton Kondrashov on 28/03/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

protocol CoursePreviewTableViewCellDelegate {
    func joinButtonTap(in cell: CoursePreviewTableViewCell)
    func playButtonTap(in cell: CoursePreviewTableViewCell)
}

class CoursePreviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var courseInfoLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    
    var delegate: CoursePreviewTableViewCellDelegate?
    
    func initWith(course: Course){
        courseNameLabel.text = course.title
        courseInfoLabel.text = course.summary
        if let video = course.introVideo{
            thumbnailImageView.sd_setImage(with: URL(string: video.thumbnailURL), placeholderImage: Images.videoPlaceholder)
        }
    }
    
    @IBAction func joinButtonTap(_ sender: UIButton) {
        delegate?.joinButtonTap(in: self)
    }
    
    @IBAction func playButtonTap(_ sender: UIButton) {
        delegate?.playButtonTap(in: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var focusGuide = UIFocusGuide()
        focusGuide.preferredFocusEnvironments = [joinButton, playButton]
        addLayoutGuide(focusGuide)
    }
}
