//
//  SortingQuizTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 27.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class SortingQuizTableViewCell: UITableViewCell {

    @IBOutlet weak var optionWebView: UIWebView!
    
    var webViewHelper : CellWebViewHelper!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        contentView.backgroundColor = UIColor.clearColor()
        webViewHelper = CellWebViewHelper(webView: optionWebView, heightWithoutWebView: 17)

        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
