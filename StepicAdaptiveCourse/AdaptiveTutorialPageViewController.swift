//
//  AdaptiveTutorialPageViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 20.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class AdaptiveTutorialPageViewController: UIViewController {
    
    var dismissHandler: () -> () = { }
    
    @IBAction func onStartLearningButtonClick(_ sender: Any) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Adaptive.onboardingFinished)
        self.dismiss(animated: true, completion: dismissHandler)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
