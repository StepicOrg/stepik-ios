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
    
    var preferredToFocus: UIFocusItem?
    
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
        
        let focusGuide = UIFocusGuide()
        focusGuide.preferredFocusEnvironments = [playButton]
        addLayoutGuide(focusGuide)
        contentView.addLayoutGuide(focusGuide)
        
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swiped(sender:)))
        swipeRecognizer.direction = [.right, .left]
        contentView.addGestureRecognizer(swipeRecognizer)
        
    }
    
    func swiped(sender: UISwipeGestureRecognizer){
        if sender.direction == .right {
           preferredToFocus = playButton
        } else {
            preferredToFocus = joinButton
        }
        
        self.setNeedsFocusUpdate()
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment]{
        return [preferredToFocus ?? joinButton]
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses{
            if press.type == .rightArrow{
                preferredToFocus = playButton
            }
            if press.type == .leftArrow{
                preferredToFocus = joinButton
            }
            
            self.setNeedsFocusUpdate()
        }
    }
}
