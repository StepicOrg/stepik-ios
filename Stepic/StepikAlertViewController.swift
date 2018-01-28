//
//  StepikAlertViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.12.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

struct StepikAlertAction {
    var title: String
    var style: UIAlertActionStyle
    var handler : (() -> Void)?

    init(title: String, style: UIAlertActionStyle, handler: (() -> Void)?) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

class StepikAlertViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var titleLabel: StepikLabel!
    @IBOutlet weak var descriptionLabel: StepikLabel!
    @IBOutlet weak var actionsView: UIView!

    var actions = [StepikAlertAction]()

    var titleText: String = ""
    var message: String = ""
    var img: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleText
        descriptionLabel.text = message
        image.image = img
        layoutActions()
        self.view.layoutSubviews()
        self.actionsView.layoutSubviews()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setup(action: StepikAlertAction, leftView: inout UIView?) {
        let b = UIButton(type: .system)
        b.setTitle(action.title, for: .normal)

        switch action.style {
        case .cancel:
            b.setTitleColor(UIColor.blue, for: .normal)
        case .default:
            b.setTitleColor(UIColor.stepicGreen, for: .normal)
        case .destructive:
            b.setTitleColor(UIColor.red, for: .normal)
        }

        actionsView.addSubview(b)
        b.addTarget(self, action: #selector(StepikAlertViewController.actionTriggered(button:)), for: .touchUpInside)
//        b.tag = actions.index(where: {
//            a in
//            return a.title == action.title
//        })
        b.tag = actions.index(where: {return $0.title == action.title}) ?? 0
//        b.tag = actions.index(of: action) ?? 0
        b.constrainWidth(toView: actionsView, predicate: "*\(1.0 / Double(actions.count))")
        b.alignTop("0", bottom: "0", toView: actionsView)
        if let lv = leftView {
            b.constrainTrailingSpace(toView: lv, predicate: "0")
        } else {
            b.constrainTrailingSpace(toView: actionsView, predicate: "0")
            leftView = b
        }
    }

    var leftView: UIView?

    func layoutActions() {

        let destructives = actions.filter({$0.style == .destructive})
        for destructive in destructives {
            setup(action: destructive, leftView: &leftView)
        }

        let cancels = actions.filter({$0.style == .cancel})
        for cancel in cancels {
            setup(action: cancel, leftView: &leftView)
        }

        let defaults = actions.filter({$0.style == .default})
        for action in defaults {
            setup(action: action, leftView: &leftView)
        }
    }

    @objc func actionTriggered(button: UIButton) {
        if button.tag < actions.count {
            if let h = actions[button.tag].handler {
                h()
            } else {
                dismiss(animated: true)
            }
        } else {
            print("triggered some strange action with id \(button.tag) in stepikAlertViewController with actions count \(actions.count)")
        }
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
