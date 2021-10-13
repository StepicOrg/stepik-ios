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

    var selectedAction: (() -> Void)?
    var cancelAction: (() -> Void)?

    var selectedBlock: (() -> Void)?
    var pickerTitle: String = ""

    var data: [String] = []

    var initialSelectedData: String?
    var selectedData: String {
        self.data[self.picker.selectedRow(inComponent: 0)]
    }

    convenience init() {
        self.init(nibName: "PickerViewController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.picker.dataSource = self
        self.picker.delegate = self

        if let initialSelectedData = self.initialSelectedData,
           let rowIndex = self.data.firstIndex(of: initialSelectedData) {
            self.picker.selectRow(rowIndex, inComponent: 0, animated: false)
        }

        self.titleLabel.text = pickerTitle

        self.localize()
        self.colorize()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.view.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.colorize()
        }
    }

    private func localize() {
        self.backButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        self.selectButton.setTitle(NSLocalizedString("Select", comment: ""), for: .normal)
    }

    private func colorize() {
        self.view.backgroundColor = .stepikAlertBackground
        self.picker.backgroundColor = .clear
    }

    @IBAction
    func backPressed(_ sender: UIButton) {
        self.cancelAction?()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction
    func selectPressed(_ sender: UIButton) {
        self.selectedAction?()
        self.dismiss(animated: true, completion: nil)
        self.selectedBlock?()
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
