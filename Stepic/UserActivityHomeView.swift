//
//  UserActivityHomeView.swift
//  Stepic
//
//  Created by Ostrenkiy on 28.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class UserActivityHomeView: NibInitializableView {
    
    @IBOutlet weak var streakCountLabel: UILabel!
    @IBOutlet weak var streakTextLabel: UILabel!
    
    override var nibName: String {
        return "UserActivity"
    }
    
    var streakCount: Int = 0 {
        didSet {
            streakCountLabel.text = "\(streakCount)"
        }
    }
    
    var shouldSolveToday: Bool = false {
        didSet {
            streakTextLabel.text = ""
        }
    }
    
    override func setupSubviews() {
        
    }
}
