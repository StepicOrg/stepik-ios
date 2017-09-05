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
                setStreaks(hidden: true)
                return
            }
            currentDaysCountLabel.text = "\(streaks.currentStreak) \(pluralizedDays(count: streaks.currentStreak))"
            maxDayCountLabel.text = "\(streaks.longestStreak) \(pluralizedDays(count: streaks.longestStreak))"
            lightningImageView.image = streaks.didSolveToday ? #imageLiteral(resourceName: "lightning_green") : #imageLiteral(resourceName: "lightning_gray")
            setStreaks(hidden: false)
        }
    }

    private func pluralizedDays(count: Int) -> String {
        return StringHelper.pluralize(number: count, forms: [NSLocalizedString("days1", comment: ""), NSLocalizedString("days234", comment: ""), NSLocalizedString("days567890", comment: "")])
    }

    private func setStreaks(hidden: Bool) {
        currentStreakLabel.isHidden = hidden
        maxStreakLabel.isHidden = hidden
        maxDayCountLabel.isHidden = hidden
        currentDaysCountLabel.isHidden = hidden
//        lightningImageView.isHidden = hidden
    }

    private func localize() {
        currentStreakLabel.text = NSLocalizedString("CurrentStreak", comment: "")
        maxStreakLabel.text = NSLocalizedString("LongestStreak", comment: "")
    }

    private func initialize() {
        containerView.setRoundedCorners(cornerRadius: 12)
        setStreaks(hidden: true)
        localize()
    }

    private var view: UIView!

    private func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        initialize()
    }

    private func loadViewFromNib() -> UIView {
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
