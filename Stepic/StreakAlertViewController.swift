//
//  StreakAlertViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.12.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class StreakAlertViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
//    var alertTitle: String = "Congrats!"
//    var message: String = "You successfully solved your first quiz. Solve quizzes every day and increase your streak! Would you like to be notified about streaks to learn every day? You can always change this option in preferences." 
//    var image: UIImage = Images.lessonPlaceholderImage.size50x50
//    
    var yesAction : ((Void) -> Void)?
    var noAction : ((Void) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = Images.lessonPlaceholderImage.size50x50

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func noPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        noAction?()
    }

    @IBAction func yesPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        yesAction?()
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
