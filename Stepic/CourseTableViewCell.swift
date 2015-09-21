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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initWithCourse(course: Course) {
        courseNameLabel.text = course.title
        
        let descData = course.courseDescription.dataUsingEncoding(NSUnicodeStringEncoding) ?? NSData()
        
        
//        courseDescriptionLabel.text = "some text"
//        var range : NSRange? = NSMakeRange(0, 1)
//        var attributes = courseDescriptionLabel.attributedText.attributesAtIndex(0, effectiveRange: &range!)
//        attributes.merge([NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType])
        
        let attributedDescription = try? NSAttributedString(data: descData, options: [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType], documentAttributes: nil) 
        let normalText = attributedDescription!.string
        courseDescriptionLabel.text = normalText
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeZone = .None
        
        if let bd = course.beginDate, 
            ed = course.endDate {
            deadlinesLabel.text = "\(formatter.stringFromDate(bd)) - \(formatter.stringFromDate(ed))"
        }
        
        courseImageView.sd_setImageWithURL(NSURL(string: course.coverURLString)!)
        
    }
}
