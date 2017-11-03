//
//  DetailViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 03.11.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var share: Int?

    @IBOutlet weak var label: UILabel!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        label.text = "\(share ?? 0) VC"
    }

}
