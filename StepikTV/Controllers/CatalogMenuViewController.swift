//
//  CatalogMenuViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 24.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class CatalogMenuViewController: MenuTableViewController {
    
    override var segueIdentifierMap: [[String]] {
        return [
            [
                "ShowUndoneCourses",
                "ShowDoneCourses"
            ]
        ]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? RectangularCollectionViewController
        
        if segue.identifier == "ShowUndoneCourses" {
            vc?.content = .Undone
        }
        
        if segue.identifier == "ShowDoneCourses" {
            vc?.content = .Done
        }
    }
}
