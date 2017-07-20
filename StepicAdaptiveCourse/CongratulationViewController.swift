//
//  CongratulationViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 20.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class CongratulationViewController: UIViewController {

    enum CongratulationType {
        var congratulationText: String {
            switch self {
            case .level(let level):
                return String(format: NSLocalizedString("NewLevelCongratulationText", comment: ""), "\(level)")
            }
        }
        var shareText: String {
            switch self {
            case .level(let level):
                return String(format: NSLocalizedString("NewLevelCongratulationShareText", comment: ""), "\(level)", "\(CongratulationViewController.shareAppName)")
            }
        }
        
        case level(level: Int)
    }
    
    var shareText = ""
    private static let shareAppName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Stepik"
    
    var text = ""
    
    var continueHandler: (() -> ())?
    
    var congratulationType: CongratulationType? {
        didSet {
            guard let type = congratulationType else {
                return
            }
            
            text = type.congratulationText
            shareText = type.shareText
        }
    }
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    
    @IBAction func onShareButtonClick(_ sender: Any) {
        guard let url = URL(string: "https://itunes.apple.com/app/id\(StepicApplicationsInfo.appId)") else {
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [shareText, url], applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityType.airDrop]
        present(activityVC, animated: true)
    }
    
    @IBAction func onContinueButtonClick(_ sender: Any) {
        dismiss(animated: true, completion: { [weak self] in
            self?.continueHandler?()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        localize()
        textLabel.text = text
    }

    fileprivate func localize() {
        shareButton.setTitle(NSLocalizedString("ShareAchievement", comment: ""), for: .normal)
        continueButton.setTitle(NSLocalizedString("Continue", comment: ""), for: .normal)
    }

}
