//
//  PlaceholderTestViewController.swift
//  OstrenkiyPlaceholderView
//
//  Created by Alexander Karpov on 09.02.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class PlaceholderTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let placeholderView = PlaceholderView()
//        placeholderView.backgroundColor = UIColor.greenColor()
        self.view.addSubview(placeholderView)
        placeholderView.alignTop("16", leading: "16", bottom: "-16", trailing: "-16", to: self.view)
        placeholderView.delegate = self
        placeholderView.datasource = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension PlaceholderTestViewController : PlaceholderViewDelegate {
    func placeholderButtonDidPress() {
        print("did press placeholder button")
    }
}

extension PlaceholderTestViewController : PlaceholderViewDataSource {
    func placeholderButtonTitle() -> String? {
        return nil
//        return "Try again"
    }
    
    func placeholderStyle() -> PlaceholderStyle {
        return stepicPlaceholderStyle
    }
    
    func placeholderDescription() -> String? {
        return "Failed to connect to the Internet. Press the button to retry or go fuck yourself"
    }
    
    func placeholderImage() -> UIImage? {
        return nil
    }
    
    func placeholderTitle() -> String? {
        return "Connection error!"
    }
}
