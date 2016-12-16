//
//  NotificationTimePickerViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 23.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class NotificationTimePickerViewController: UIViewController {

    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var selectTimeLabel: UILabel!
    
    var selectedBlock: ((Void) -> Void)? 
    var startHour : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        picker.dataSource = self
        picker.delegate = self
        picker.selectRow(startHour, inComponent: 0, animated: false)
        
        localize()
        // Do any additional setup after loading the view.
    }

    func localize() {
        backButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        selectButton.setTitle(NSLocalizedString("Select", comment: ""), for: .normal)
        selectTimeLabel.text = NSLocalizedString("SelectTimeTitle", comment: "")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    @IBAction func backPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectPressed(_ sender: UIButton) {
        
        let selectedLocalStartHour = picker.selectedRow(inComponent: 0)
        let timeZoneDiff = NSTimeZone.system.secondsFromGMT() / 3600
        var selectedUTCStartHour = selectedLocalStartHour - timeZoneDiff
        
        if selectedUTCStartHour < 0 {
            selectedUTCStartHour = 24 + selectedUTCStartHour
        }
        
        if selectedUTCStartHour > 23 {
            selectedUTCStartHour = selectedUTCStartHour - 24
        }
        
        print("selected UTC start hour -> \(selectedUTCStartHour)")
        
        PreferencesContainer.notifications.streaksNotificationStartHourUTC = selectedUTCStartHour
        LocalNotificationManager.scheduleStreakLocalNotification(UTCStartHour: selectedUTCStartHour)

    
        
        dismiss(animated: true, completion: nil)
        selectedBlock?()
    }
    
    func getDisplayingStreakTimeInterval(startHour: Int) -> String {
        
        let timeZoneDiff = NSTimeZone.system.secondsFromGMT()
        let startInterval = TimeInterval((startHour % 24) * 60 * 60 - timeZoneDiff)
        let startDate = Date(timeIntervalSinceReferenceDate: startInterval)
        let endInterval = TimeInterval((startHour + 1) % 24 * 60 * 60 - timeZoneDiff) 
        let endDate = Date(timeIntervalSinceReferenceDate: endInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        return "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"
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

extension NotificationTimePickerViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 24
    }
}

extension NotificationTimePickerViewController : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return getDisplayingStreakTimeInterval(startHour: row)
    }
}
