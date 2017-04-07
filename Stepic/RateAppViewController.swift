//
//  RateAppViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 07.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class RateAppViewController: UIViewController {

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var laterButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var centerViewWidth: NSLayoutConstraint!
    
    @IBOutlet var starImageViews: [UIImageView]!
    
    @IBOutlet weak var buttonsContainerHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        centerViewWidth.constant = 0.5
        buttonsContainerHeight.constant = 0

        let tapG = UITapGestureRecognizer(target: self, action: #selector(RateAppViewController.didTap(recognizer:)))
        
        starImageViews.forEach{
            $0.addGestureRecognizer(tapG)
        }
        
        // Do any additional setup after loading the view.
    }

    func didTap(recognizer: UIGestureRecognizer) {
        guard let tappedIndex = recognizer.view?.tag else {
            return
        }
        
        starImageViews.forEach{
            if $0.tag <= tappedIndex {
                $0.isHighlighted = true
            }
            $0.isUserInteractionEnabled = false
        }
        
        buttonsContainerHeight.constant = 48
        
        let rating = tappedIndex + 1 
        if rating < 4 {
            rightButton.setTitle("Email", for: .normal)
        } else {
            rightButton.setTitle("App Store", for: .normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
