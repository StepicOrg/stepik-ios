 //
 //  CourseTableViewCell.swift
 //  Stepic
 //
 //  Created by Alexander Karpov on 15.09.15.
 //  Copyright (c) 2015 Alex Karpov. All rights reserved.
 //
 
 import UIKit
 import SDWebImage
 
 class CourseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var courseImageView: UIImageView!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var courseDescriptionLabel: UILabel!
    @IBOutlet weak var deadlinesLabel: UILabel!
    #if os(iOS)
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var deadlineLabelHeight: NSLayoutConstraint! //14
    @IBOutlet weak var continueButtonHeight: NSLayoutConstraint! //32
    #endif
    
    var continueAction : ((Void) -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        #if os(iOS)
            continueButton.setStepicWhiteStyle()
            continueButton.setTitle(NSLocalizedString("ContinueLearning", comment: ""), for: .normal)
        #endif
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    fileprivate func getTextFromDates(_ course: Course) -> String {
        
        if course.beginDate == nil && course.endDate == nil {
            return ""
        }
        
        if course.beginDate == nil && course.endDate != nil {
            return "\(NSLocalizedString("until", comment: "")) \(course.endDate!.getStepicFormatString())"
        }
        
        if course.beginDate != nil && course.endDate == nil {
            return "\(NSLocalizedString("from", comment: "")) \(course.beginDate!.getStepicFormatString())"
        }
        
        return "\(course.beginDate!.getStepicFormatString()) - \(course.endDate!.getStepicFormatString())"
    }
    
    func initWithCourse(_ course: Course) {
        courseNameLabel.text = course.title
        
        courseDescriptionLabel.setTextWithHTMLString(course.summary)
        
        let deadlinesText = getTextFromDates(course)
        
        #if os(iOS)
            if deadlinesText == "" {
                deadlineLabelHeight.constant = 0
            } else {
                deadlinesLabel.text = deadlinesText
                deadlineLabelHeight.constant = 14
            }
            
            if course.enrolled {
                continueButtonHeight.constant = 32
            } else {
                continueButtonHeight.constant = 0
            }
        #endif
        
        courseImageView.sd_setImage(with: URL(string: course.coverURLString), placeholderImage: Constants.placeholderImage)
        
    }
    
    #if os(iOS)
    @IBAction func continueButtonPressed(_ sender: UIButton) {
    continueAction?()
    }
    #endif
    
    
 }
