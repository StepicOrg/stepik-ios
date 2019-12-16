//
//  PickerViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.02.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController {
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var titleLabel: StepikLabel!

    var selectedBlock: (() -> Void)?
    var pickerTitle: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        picker.dataSource = self
        picker.delegate = self

        titleLabel.text = pickerTitle

        localize()
    }

    func localize() {
        backButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        selectButton.setTitle(NSLocalizedString("Select", comment: ""), for: .normal)
    }

    var selectedAction : (() -> Void)?
    var cancelAction : (() -> Void)?

    var data: [String] = []

    @IBAction func backPressed(_ sender: UIButton) {
        cancelAction?()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func selectPressed(_ sender: UIButton) {
        selectedAction?()
        dismiss(animated: true, completion: nil)
        selectedBlock?()
    }

    var selectedData: String {
        self.data[self.picker.selectedRow(inComponent: 0)]
    }
}

extension PickerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        self.data.count
    }
}

extension PickerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.data[row]
    }
}
