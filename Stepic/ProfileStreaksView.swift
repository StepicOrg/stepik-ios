//
//  ProfileStreaksView.swift
//  Stepic
//
//  Created by Ostrenkiy on 02.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class ProfileStreaksView: UIView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var avatarImageView: AvatarImageView!

    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var lightningImageView: UIImageView!
    @IBOutlet weak var currentDaysCountLabel: UILabel!
    @IBOutlet weak var maxDayCountLabel: UILabel!
    @IBOutlet weak var currentStreakLabel: UILabel!
    @IBOutlet weak var maxStreakLabel: UILabel!

    var profile: ProfileData? {
        didSet {
            guard let profile = profile, let url = URL(string: profile.avatarURLString) else {
                return
            }
            avatarImageView.set(with: url)
            firstNameLabel.text = profile.firstName
            lastNameLabel.text = profile.lastName
        }
    }

    var streaks: StreakData? {
        didSet {
            guard let streaks = streaks else {
                return
            }
            currentDaysCountLabel.text = "\(streaks.currentStreak) days"
            maxDayCountLabel.text = "\(streaks.longestStreak) days"
            lightningImageView.image = streaks.didSolveToday ? #imageLiteral(resourceName: "lightning_green") : #imageLiteral(resourceName: "lightning_gray")
        }
    }

    fileprivate func initialize() {
        containerView.setRoundedCorners(cornerRadius: 12)
    }

    fileprivate var view: UIView!

    fileprivate func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        initialize()
    }

    fileprivate func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ProfileStreaksView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }

    override init(frame: CGRect) {
        // 1. setup any properties here

        // 2. call super.init(frame:)
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here

        // 2. call super.init(coder:)
        super.init(coder: aDecoder)

        // 3. Setup view from .xib file
        setup()
    }

}
