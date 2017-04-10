//
//  RateAppViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 07.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import MessageUI

class RateAppViewController: UIViewController {

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var laterButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var centerViewWidth: NSLayoutConstraint!
    
    @IBOutlet var starImageViews: [UIImageView]!
    
    @IBOutlet weak var buttonsContainerHeight: NSLayoutConstraint!
    
    enum AfterRateActionType {
        case appStore, email
    }
    
    var buttonState : AfterRateActionType? = nil {
        didSet {
            guard buttonState != nil else {
                return
            }
            
            switch buttonState! {
            case AfterRateActionType.appStore:
                rightButton.setTitle("Email", for: .normal)
                break
            case AfterRateActionType.email:
                rightButton.setTitle("AppStore", for: .normal)
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        centerViewWidth.constant = 0.5
        buttonsContainerHeight.constant = 0

        
        for star in starImageViews {
            let tapG = UITapGestureRecognizer(target: self, action: #selector(RateAppViewController.didTap(_:)))
            star.isUserInteractionEnabled = true
            star.addGestureRecognizer(tapG)
        }
        
        // Do any additional setup after loading the view.
    }

    func didTap(_ recognizer: UITapGestureRecognizer) {
        guard let tappedIndex = recognizer.view?.tag else {
            return
        }
        
        for star in starImageViews {
            if star.tag <= tappedIndex {
                star.isHighlighted = true
            }
            star.isUserInteractionEnabled = false
        }
        
        buttonsContainerHeight.constant = 48
        
        let rating = tappedIndex + 1 
        if rating < 4 {
            buttonState = .email
        } else {
            buttonState = .appStore
        }
    }
    
    func showEmail() {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        composeVC.setToRecipients(["address@example.com"])
        composeVC.setSubject("Hello!")
        composeVC.setMessageBody("Hello from California!", isHTML: false)
        
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func showAppStore() {
        guard let appStoreURL = URL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1064581926&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software&action=write-review") else {
            return
        }
        UIApplication.shared.openURL(appStoreURL)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func laterButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func rightButtonPressed(_ sender: UIButton) {
        guard buttonState != nil else {
            return
        }
        
        switch buttonState! {
        case AfterRateActionType.appStore:
            showEmail()
            break
        case AfterRateActionType.email:
            showAppStore()
            break
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RateAppViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        

        self.dismiss(animated: true, completion: {
//            controller.dismiss(animated: true, completion: nil)
        })
    }
}
