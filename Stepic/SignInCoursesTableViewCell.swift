//
//  SignInCoursesTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.07.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class SignInCoursesTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    
    var signInPressedAction: ((Void)->(Void))?
    
    fileprivate func localize() {
        titleLabel.text = NSLocalizedString("NotWithUsYet", comment: "")
        descriptionLabel.text = NSLocalizedString("JoinCoursesSuggestionDescription", comment: "")
        signInButton.setTitle(NSLocalizedString("SignIn", comment: ""), for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        localize()
        
        titleLabel.textColor = UIColor.darkGray
        descriptionLabel.textColor = UIColor.lightGray
        signInButton.tintColor = UIColor.stepicGreenColor()
    }

    @IBAction func signInPressed(_ sender: Any) {
        signInPressedAction?()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
