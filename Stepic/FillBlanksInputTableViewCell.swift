//
//  FillBlanksInputTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 11.02.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

//Preferrable height equals 44

import UIKit

class FillBlanksInputTableViewCell: UITableViewCell {

    @IBOutlet weak var inputTextField: UITextField!

    let placeholderString: String = NSLocalizedString("FillBlankInputTextFieldPlaceholder", comment: "")

    var answerDidChange: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        inputTextField.placeholder = placeholderString
        inputTextField.returnKeyType = .done
        inputTextField.delegate = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func textFieldDidChange(_ sender: UITextField) {
        answerDidChange?(inputTextField.text ?? "")
    }

    var answer: String? = "" {
        didSet {
            inputTextField.text = answer
        }
    }

    static let defaultHeight: CGFloat = 52

}

extension FillBlanksInputTableViewCell : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
