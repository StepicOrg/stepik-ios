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
    @IBOutlet weak var titleLabel: UILabel!
    
    var selectedBlock: ((Void) -> Void)? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.dataSource = self
        picker.delegate = self
        
        localize()
        // Do any additional setup after loading the view.
    }
    
    func localize() {
        backButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        selectButton.setTitle(NSLocalizedString("Select", comment: ""), for: .normal)
    }
        
    var selectedAction : ((Void)->Void)?
    
    var data : [String] = []
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectPressed(_ sender: UIButton) {
        selectedAction?()
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

extension PickerViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
}

extension PickerViewController : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row]
    }
}
