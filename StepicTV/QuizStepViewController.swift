//
//  QuizStepViewController.swift
//  Stepic
//
//  Created by Anton Kondrashov on 29/03/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftSoup

class QuizStepViewController: UIViewController {
    
    @IBOutlet weak var taskTextView: UITextView!
    
    var step: Step!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        guard let def = step.block.text else { return }
        do {
            let doc = try SwiftSoup.parse(def)
            taskTextView.text = try doc.text()
        } catch {
            print(error)
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
