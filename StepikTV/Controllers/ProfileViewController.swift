//
//  ProfileViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 29.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet var upperButton: StandardButton!
    
    @IBOutlet var midButton: StandardButton!
    
    @IBOutlet var lowerButton: StandardButton!
    
    override func viewDidAppear(_ animated: Bool) {
        print(midButton.layer.cornerRadius)
    }
    
}
