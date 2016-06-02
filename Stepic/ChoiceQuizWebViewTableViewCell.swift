//
//  ChoiceQuizWebViewTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import BEMCheckBox

class ChoiceQuizWebViewTableViewCell: UITableViewCell {

    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var choiceWebView: UIWebView!
    @IBOutlet weak var webViewHeight: NSLayoutConstraint!
    
    var webViewHelper : CellWebViewHelper!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkBox.onAnimationType = .Fill
        checkBox.animationDuration = 0.3
        contentView.backgroundColor = UIColor.clearColor()
        webViewHelper = CellWebViewHelper(webView: choiceWebView, heightWithoutWebView: 17)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    deinit{
        print("did deinit cell")
    }
    
}
