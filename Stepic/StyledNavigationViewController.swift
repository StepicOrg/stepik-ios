//
//  StyledNavigationViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.09.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class StyledNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarStyle()
        navigationBar.barTintColor = UIColor.mainLightColor
        navigationBar.isTranslucent = false
        let fontSize: CGFloat = 17.0
        var titleFont: UIFont = UIFont.systemFont(ofSize: fontSize)
        if #available(iOS 8.2, *) {
            titleFont = UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightLight)
        }
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.mainDarkColor, NSFontAttributeName: titleFont]
        navigationBar.tintColor = UIColor.mainDarkColor
    }

    func setStatusBarStyle() {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
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
