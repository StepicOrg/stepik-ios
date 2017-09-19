//
//  StreakAlertViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.12.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class StreakAlertViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: StepikLabel!
    @IBOutlet weak var messageLabel: StepikLabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    var currentStreak: Int = 0
//    var alertTitle: String = "Congrats!"
//    var message: String = "You successfully solved your first quiz. Solve quizzes every day and increase your streak! Would you like to be notified about streaks to learn every day? You can always change this option in preferences." 
//    var image: UIImage = Images.lessonPlaceholderImage.size50x50
//    
    var yesAction : (() -> Void)?
    var noAction : (() -> Void)?

    var messageLabelWidth: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        messageLabelWidth = messageLabel.constrainWidth("<=\(UIScreen.main.bounds.width - 48)")

        localize()
        // Do any additional setup after loading the view.
    }

    func dayLocalizableFor(daysCnt: Int) -> String {
        switch (daysCnt % 10) {
        case 1: return NSLocalizedString("days1", comment: "")
        case 2, 3, 4: return NSLocalizedString("days234", comment: "")
        default: return NSLocalizedString("days567890", comment: "")
        }
    }

    func localize() {
        titleLabel.text = NSLocalizedString("StreakAlertTitle", comment: "")
        messageLabel.text = String(format: NSLocalizedString("StreakAlertMessage", comment: ""), "\(currentStreak)", dayLocalizableFor(daysCnt: currentStreak))
        noButton.setTitle(NSLocalizedString("No", comment: ""), for: .normal)
        yesButton.setTitle(NSLocalizedString("Yes", comment: ""), for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func noPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        PreferencesContainer.notifications.allowStreaksNotifications = false
        AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.Suggestion.fail(QuizDataManager.submission.streakAlertShownCnt), parameters: nil)
        noAction?()
    }

    @IBAction func yesPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        PreferencesContainer.notifications.allowStreaksNotifications = true
        AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.Suggestion.success(QuizDataManager.submission.streakAlertShownCnt), parameters: nil)
        yesAction?()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        messageLabelWidth?.constant = UIScreen.main.bounds.height - 48
    }

}
