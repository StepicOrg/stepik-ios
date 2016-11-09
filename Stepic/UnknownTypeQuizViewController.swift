//
//  UnknownTypeQuizViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class UnknownTypeQuizViewController: UIViewController {

    var stepUrl : String!
    var delegate : QuizControllerDelegate?
    
    @IBOutlet weak var solveOnTheWebsiteButton: UIButton!
    
    @IBAction func solveOnTheWebsitePressed(_ sender: UIButton) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Step.Submission.solveInWebPressed, parameters: nil)
        let url = URL(string: stepUrl.addingPercentEscapes(using: String.Encoding.utf8)!)!
        
        WebControllerManager.sharedManager.presentWebControllerWithURL(url, inController: self, withKey: "external link", allowsSafari: true, backButtonStyle: BackButtonStyle.close)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        solveOnTheWebsiteButton.setRoundedCorners(cornerRadius: 8, borderWidth: 0, borderColor: UIColor.stepicGreenColor())
        solveOnTheWebsiteButton.setTitle(NSLocalizedString("SolveOnTheWebsite", comment: ""), for: UIControlState())
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        delegate?.needsHeightUpdate(56, animated: true)
        view.layoutIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
