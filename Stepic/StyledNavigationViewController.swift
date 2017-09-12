//
//  StyledNavigationViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.09.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class StyledNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupShadowView()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarStyle()
        navigationBar.barTintColor = UIColor.mainLightColor
        navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
        let fontSize: CGFloat = 17.0
        let titleFont = UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightLight)
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.mainDarkColor, NSFontAttributeName: titleFont]
        navigationBar.tintColor = UIColor.mainDarkColor
    }

    func reloadShadowView() {
        if let v = customShadowView {
            v.removeFromSuperview()
        }
        setupShadowView()
    }

    func setStatusBarStyle() {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }

    var customShadowView: UIView?
    var customShadowTrailing: NSLayoutConstraint?

    func setupShadowView() {
        let v = UIView()
        navigationBar.addSubview(v)
        v.backgroundColor = UIColor.lightGray
        _ = v.constrainHeight("0.5")
        _ = v.alignBottomEdge(with: navigationBar, predicate: "0")
        _ = v.alignLeadingEdge(with: navigationBar, predicate: "0")
        self.customShadowTrailing = v.alignTrailingEdge(with: navigationBar, predicate: "0").first as? NSLayoutConstraint
        customShadowView = v
        customShadowView?.alpha = 1
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
