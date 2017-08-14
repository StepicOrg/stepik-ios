//
//  CodeLanguagePickerViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 24.06.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class CodeLanguagePickerViewController: PickerViewController {

    var languages: [String] = [] {
        didSet {
            data = languages
            if picker != nil { picker.reloadAllComponents() }
        }
    }
    var startLanguage: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = NSLocalizedString("SelectLanguage", comment: "")

        data = languages
        picker.reloadAllComponents()
        if let start = languages.index(of: startLanguage) {
            picker.selectRow(start, inComponent: 0, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
